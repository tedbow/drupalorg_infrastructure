#!/bin/bash -eux

# Name:        base.sh
# Author:      Nick Schuch (nick@myschuch.com)
# Description: Install base packages and configuration.
date
apt-get update
apt-get -y upgrade
apt-get -y install curl

# Add sysdig sources to monitor the testbot workload
curl -s https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public | apt-key add -
curl -s -o /etc/apt/sources.list.d/draios.list http://download.draios.com/stable/deb/draios.list
LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
apt-get update

# Packages.
apt-get -y install bsdtar dstat gawk git grep htop iotop linux-headers-$(uname -r) \
                   make mc mysql-client nmon ntp \
                   openjdk-7-jre php7.1 php7.1-mysql php7.1-mbstring php7.1-pgsql php7.1-sqlite3 php7.1-xml php7.1-bcmath php7.1-curl php7.1-cli php7.1-dev php-pear python sqlite3 ssh \
                   sudo sysstat vim wget sysdig php-xdebug
apt-get clean
apt-get -y autoremove
# we want xdebug there, just disabled.
phpdismod xdebug

# Composer.

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === 'c32408bcd017c577ce80605420e5987ce947a5609e8443dd72cd3867cc3a0cf442e5bf4edddbcbe72246a953a6c48e21') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php --filename=composer --install-dir=/usr/local/bin --preview
php -r "unlink('composer-setup.php');"
chmod +x /usr/local/bin/composer && ln -s /usr/local/bin/composer /usr/bin/composer

sed -i 's/; sys_temp_dir = "\/tmp"/sys_temp_dir = "\/var\/lib\/drupalci\/workspace\/"/g' /etc/php/7.1/cli/php.ini
sed -i 's/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g' /etc/php/7.1/cli/php.ini

# drupalci dir




# prep for core files
echo "/tmp/cores/core.%e.%p.%t" > /proc/sys/kernel/core_pattern

# Jenkins Slave configuration
(
cat << EOF
#!/usr/bin/python
import os
import httplib
import string

# If java is installed it will be zero
# If java is not installed it will be non-zero
hasJava = os.system("java -version")

if hasJava != 0:
    os.system("sudo apt-get update")
    os.system("sudo apt-get install openjdk-7-jre -y")

conn = httplib.HTTPConnection("169.254.169.254")
conn.request("GET", "/latest/user-data")
response = conn.getresponse()
userdata = response.read()

args = string.split(userdata, "&")
jenkinsUrl = ""
slaveName = ""

for arg in args:
    if arg.split("=")[0] == "JENKINS_URL":
        jenkinsUrl = arg.split("=")[1]
    if arg.split("=")[0] == "SLAVE_NAME":
        slaveName = arg.split("=")[1]

# Use dispatcher-origin.drupalci.aws for these requests in order to make the
# jnlp connection to the correct server (directly to jenkins, bypassing the elb)
os.system("wget " + jenkinsUrl + "jnlpJars/slave.jar -O slave.jar")
os.system("java -jar slave.jar -jnlpCredentials drupaltestbotslave:j190U2l7HCYp7SKDTfM9azhBqz0Ggjw -jnlpUrl " + jenkinsUrl + "/computer/" + slaveName + "/slave-agent.jnlp")

EOF
) > /usr/bin/userdata
chmod +x /usr/bin/userdata

#Size the tmpfs volume based on the amount of available memory
MEMSIZE=`cat /proc/meminfo |grep MemTotal |awk '{printf "%d", $2*.70;}'`

sed --in-place -e 's/exit 0//' /etc/rc.local
(
cat << EOF
mkdir -p /var/lib/drupalci
mount -t tmpfs -o size=${MEMSIZE}k tmpfs /var/lib/drupalci
mkdir /var/lib/drupalci/workspace
# TODO: deprecate web, should be workspace.
mkdir /var/lib/drupalci/web
mkdir /var/lib/drupalci/docker-tmp
chown -R ubuntu:ubuntu /var/lib/drupalci /home/ubuntu
chmod 777 /var/lib/drupalci/docker-tmp
python /usr/bin/userdata
exit 0
EOF
) >> /etc/rc.local
