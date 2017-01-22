#!/usr/bin/env bash

TESTRUNNER_DIR="/opt/drupalci/testrunner"
# Create the script that jenkins will run:
(
cat << 'EOF'
docker ps |grep drupalci |awk '{print $1}' |xargs docker stop &> /dev/null||true; docker ps -a |grep drupalci |awk '{print $1}' |xargs docker rm &>/dev/null || true
find /var/lib/drupalci/workspace -mindepth 1 -maxdepth 1 -mtime +7 -exec sudo rm -rf "{}" \;

set -uex
id
export COMPOSER_CACHE_DIR="/opt/drupalci/composer-cache"
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
