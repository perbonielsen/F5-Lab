#!/bin/bash

# The purpose of this script is to setup the required components for the F5
# automation lab Linux server
#
# This script is processed by cfn-init and will be run as root.
#
# You can monitor the progress of the packages install through
# /var/log/cfn-init-cmd.log. Here you will see all the different commands run
# from the Cloud Formation Template and through this script
#
# It takes approx. 5 min to have the instance fully setup

#ifconfig eth1 10.1.1.250 netmask 255.255.255.0
#ifconfig eth0 10.1.20.100 netmask 255.255.255.0
#ifconfig eth0:1 10.1.20.101 netmask 255.255.255.0
#ifconfig eth0:2 10.1.20.102 netmask 255.255.255.0
#ifconfig eth0:3 10.1.20.103 netmask 255.255.255.0

touch /home/ubuntu/alert3-server-install-started-wait-about-7min

# Disable SSH Host Key Checking for hosts in the lab
cat << 'EOF' >> /etc/ssh/sshd_config

Host 10.1.*.*
   StrictHostKeyChecking no
   UserKnownHostsFile /dev/null
   LogLevel ERROR	

EOF

# Install dnsmasq
apt-get install -y dnsmasq
# these entries are added by AWS commands
#cat << 'EOF' > /etc/dnsmasq.d/f5lab
#listen-address=127.0.0.1,10.1.20.100,10.1.20.101,20.1.10.102,10.1.20.103
#no-dhcp-interface=lo0,eth0,eth0:1,eth0:2,eth0:3,eth1
#EOF
systemctl enable dnsmasq.service
service dnsmasq start

# Install ubuntu docker
#apt-get update
#apt-get install -y docker.io
#sleep 2

# Install official docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
sleep 2

# Start the f5-demo-httpd container
cat << 'EOF' > /etc/rc.local
#!/bin/sh -e
docker run -d -p 80:80 --restart unless-stopped -e F5DEMO_APP=website -e F5DEMO_COLOR=FF0000 -e F5DEMO_NODENAME='Red' f5devcentral/f5-demo-httpd
docker run -d -p 8000:80 --restart unless-stopped -e F5DEMO_APP=website -e F5DEMO_COLOR=FF8000 -e F5DEMO_NODENAME='Orange' f5devcentral/f5-demo-httpd
docker run -d -p 8001:80 --restart unless-stopped -e F5DEMO_APP=website -e F5DEMO_COLOR=A0A0A0 -e F5DEMO_NODENAME='Gray' f5devcentral/f5-demo-httpd
docker run -d -p 8002:80 --restart unless-stopped -e F5DEMO_APP=website -e F5DEMO_COLOR=33FF33 -e F5DEMO_NODENAME='Green' f5devcentral/f5-demo-httpd
docker run -d -p 8003:80 --restart unless-stopped -e F5DEMO_APP=website -e F5DEMO_COLOR=3333FF -e F5DEMO_NODENAME='Blue' f5devcentral/f5-demo-httpd
EOF

touch /home/ubuntu/alert4-finished-jumphost-setup-script

# To avoid lab running and costing money, shutdown daily :
# Use 'shutdown -c ' to cancel
cat << 'EOF' >> /etc/rc.local
#!/bin/sh -e
shutdown -h 23:59
EOF

sleep 1
touch /home/ubuntu/alert5-daily-autoshutdown-configured
sleep 2
touch /home/ubuntu/alert6-setup-finished-reboot-in-10s
sleep 10
reboot

