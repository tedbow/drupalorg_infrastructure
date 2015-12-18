#!/bin/bash -eux

# Name:        base.sh
# Description: Install base packages and configuration.
date
apt-get update
apt-get -y upgrade

# Packages.
apt-get -y install bsdtar curl dstat gawk git grep htop iotop linux-headers-$(uname -r) \
                   nmon ntp openjdk-7-jre python sqlite3 ssh sysstat vim wget
apt-get clean
apt-get -y autoremove

# disable ssh strict checking
echo 'Host *' > /home/ubuntu/.ssh/config
echo 'StrictHostKeyChecking no' >> /home/ubuntu/.ssh/config

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

# Use bdd-dispatcher-origin.drupalcsystems.aws for these requests in order to make the
# jnlp connection to the correct server (directly to jenkins, bypassing the elb)
os.system("wget " + jenkinsUrl + "jnlpJars/slave.jar -O slave.jar")
os.system("java -jar slave.jar -jnlpCredentials slave:Ziejee7zeimah3Pishao7eiPOhVoh8ot -jnlpUrl " + jenkinsUrl + "/computer/" + slaveName + "/slave-agent.jnlp")

EOF
) > /usr/bin/userdata
chmod +x /usr/bin/userdata

sed --in-place -e 's/exit 0//' /etc/rc.local
(
cat << EOF

# disable ssh strict checking
echo 'Host *' > /home/ubuntu/.ssh/config
echo '  StrictHostKeyChecking no' >> /home/ubuntu/.ssh/config

python /usr/bin/userdata
exit 0
EOF
) >> /etc/rc.local
