echo "Install wget"
yum install wget -y
echo "Create tmp directory"
mkdir tmp
cd /tmp
sleep 5
echo "Download Splunk"
sleep 5
wget -O splunkforwarder-9.0.1-82c987350fde-Linux-x86_64.tgz "https://download.splunk.com/products/universalforwarder/releases/9.0.1/linux/splunkforwarder-9.0.1-82c987350fde-Linux-x86_64.tgz"
echo "Splunk Downloaded"
sleep 10
tar -xvzf splunkforwarder-9.0.1-82c987350fde-Linux-x86_64.tgz -C /opt
echo "Package untarded on opt directory"
sleep 10
rm -rf /tmp/splunkforwarder-9.0.1-82c987350fde-Linux-x86_64.tgz
echo "Package Deleted"
sleep 10
mkdir /opt/splunkforwarder/etc/apps/uf_deployment_client
create_seed(){
        echo "Creating user-seed.conf"
        echo "[user_info]" > /opt/splunkforwarder/etc/system/local/user-seed.conf
        echo "USERNAME = admin" >> /opt/splunkforwarder/etc/system/local/user-seed.conf
        echo "PASSWORD = <password>" >> /opt/splunkforwarder/etc/system/local/user-seed.conf
}
create_deployment(){
	echo "Creating deploymentclient.conf"
	echo "[target-broker:deploymentServer]" > /opt/splunkforwarder/etc/system/local/deploymentclient.conf
	echo "targetUri= https://<Deployment_Server>:8089" >> /opt/splunkforwarder/etc/system/local/deploymentclient.conf
	echo "phoneHomeIntervalInSecs=3600" >> /opt/splunkforwarder/etc/system/local/deploymentclient.conf
}
sleep 10
echo "Creating user's credentials"
create_seed
echo "User credentials succesfully created"
sleep 10
echo "Deployment succesfully created"
create_deployment
sleep 10
echo "Start splunk with accepting license"
/opt/splunkforwarder/bin/splunk start --accept-license --no-prompt
echo "Please wait for splunk to start"
sleep 10
echo "Installation Completed"
sleep 5
echo "Checking Splunk status"
/opt/splunkforwarder/bin/splunk status
useradd splunk
groupadd splunk
chmod 770 /opt/splunkforwarder
chown -R splunk:splunk /opt/splunkforwarder
