TGZ=splunk-7.3.0-657388c7a488-Linux-x86_64.tgz
SPLUNKUSER=splunk
SPPATH=/opt
ADMINUSER=admin
ADMINPASS=admin1234
RCLOCAL=/etc/rc.d/rc.local
INSTALLOC=`pwd`

install-splunk() {
cd ${SPPATH}
tar -xvzf ${TGZ} -C ${SPPATH}
}

disable-thp() {
grep THP ${RCLOCAL} > /dev/null 2>&1
if [[ $? != 0 ]]
 then
echo "disabing THP"
cat ${INSTALLOC}/splunk-rc-local.txt >>${RCLOCAL}
chmod 755 ${RCLOCAL}
else
echo "THP is already disabled in ${RCLOCAL}"
fi
}

create_user_seed(){
echo "Creating user-seed.conf"
echo "[user_info]" > ${SPPATH}/splunk/etc/system/local/user-seed.conf
echo "USERNAME = ${ADMINUSER}" >> ${SPPATH}/splunk/etc/system/local/user-seed.conf
echo "PASSWORD = ${ADMINPASS}" >> ${SPPATH}/splunk/etc/system/local/user-seed.conf
}

firewall-iptables() {
echo "Adding firewall rules"
iptables -F
iptables-save | sudo tee /etc/sysconfig/iptables
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8000 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 9997 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 514 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables-save | sudo tee /etc/sysconfig/iptables
service iptables restart
}

firewall_firewall-cmd() {
[[ `which firewall-cmd` ]] && {
echo "Adding firewall rules"
firewall-cmd --permanent --add-port=8000/tcp
firewall-cmd --reload
}
}

add-splunk-user() {
echo "Adding user ${SPLUNKUSER}"
useradd ${SPLUNKUSER}
groupadd ${SPLUNKUSER}
}

chown-splunkdir() {
echo "chowning ${SPPATH}/splunk"
chown -R splunk:splunk ${SPPATH}/splunk
}
add-to-security-limits() {
grep splunk /etc/security/limits.conf >/dev/null 2>&1
if [[ $? != 0 ]]
 then
        echo "Adding ULIMITS to /etc/security/limits.conf"
        echo "${SPLUNKUSER} hard core 0" >> /etc/security/limits.conf
        echo "${SPLUNKUSER} hard maxlogins 10" >> /etc/security/limits.conf
        echo "${SPLUNKUSER} soft nofile 65535" >> /etc/security/limits.conf
        echo "${SPLUNKUSER} hard nofile 65535" >> /etc/security/limits.conf
        echo "${SPLUNKUSER} soft nproc 20480" >> /etc/security/limits.conf
        echo "${SPLUNKUSER} hard nproc 20480" >> /etc/security/limits.conf
        echo "${SPLUNKUSER} soft fsize unlimited" >> /etc/security/limits.conf
        echo "${SPLUNKUSER} hard fsize unlimited" >> /etc/security/limits.conf
 else
echo "limits.conf already configured"
fi
}

enable-bootstart() {
echo "enabling ${SPLUNKUSER} bootstart"
/opt/splunk/bin/splunk enable boot-start -user ${SPLUNKUSER}
chmod 755 /etc/init.d/splunk
}

rewrite-splunk-start() {
echo "Writing startup script"
cp ${INSTALLOC}/splunk-initd.txt /etc/init.d/splunk
chmod 755 /etc/init.d/splunk
}

wget-splunk
install-splunk
firewall-iptables
firewall_firewall-cmd
create_user_seed
${SPPATH}/splunk/bin/splunk start --accept-license --no-prompt
echo "PLEASE WAIT FOR SPLUNK TO STOP AND INSTALLATION WILL CONTINUE"
sleep 30
${SPPATH}/splunk/bin/splunk stop
disable-thp
add-to-security-limits
add-splunk-user
chown-splunkdir
enable-bootstart
rewrite-splunk-start
