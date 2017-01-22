#!/usr/bin/env bash

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

sed --in-place -e 's/exit 0//' /etc/rc.local
(
cat << "EOF"
python /usr/bin/userdata

exit 0
EOF
) >> /etc/rc.local

# Create the script that jenkins will run:
(
cat << 'EOF'
docker ps |grep drupalci |awk '{print $1}' |xargs docker stop &> /dev/null||true; docker ps -a |grep drupalci |awk '{print $1}' |xargs docker rm &>/dev/null || true
find /var/lib/drupalci/workspace -mindepth 1 -maxdepth 1 -mtime +7 -exec sudo rm -rf "{}" \;

set -uex
id
echo https://www.drupal.org/pift-ci-job/${Drupal_JobID#https://www.drupal.org:}
curl -w '\n' -s http://169.254.169.254/latest/meta-data/instance-type
curl -w '\n' -s http://169.254.169.254/latest/meta-data/ami-id
curl -w '\n' -s http://169.254.169.254/latest/meta-data/public-ipv4
#Get rid of web files over 7 days old
env |grep DCI
env |grep -v DCI

cd /opt/drupalci/testrunner

git fetch --all --tags
git checkout ${Testrunner_Branch}
git pull --rebase
docker pull drupalci/${DCI_PHPVersion}

# Make sure that any composer changes to drupalci_testbot are picked up
# If a container rebuild has not happened yet.
/usr/local/bin/composer install --no-progress --no-suggest

./drupalci run ${DCI_JobType}
EOF
) > ${TESTRUNNER_DIR}/jenkins.sh
chmod +x ${TESTRUNNER_DIR}/jenkins.sh
chown testbot:testbot ${TESTRUNNER_DIR}/jenkins.sh
