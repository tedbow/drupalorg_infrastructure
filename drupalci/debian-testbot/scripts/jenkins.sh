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