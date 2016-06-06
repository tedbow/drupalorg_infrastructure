#!/bin/bash
set -uex
curl -w '\n' -s http://169.254.169.254/latest/meta-data/instance-type
curl -w '\n' -s http://169.254.169.254/latest/meta-data/ami-id
curl -w '\n' -s http://169.254.169.254/latest/meta-data/public-ipv4

DOCKERSELEINUMOPTS='--name=selenium -e JAVA_OPTS=-Djava.security.egd=file:/dev/./urandom -p 4444:4444 '
nc -vz localhost 4444 || ( docker run -d ${DOCKERSELEINUMOPTS} selenium/standalone-firefox && sleep 20 )
nc -vz localhost 4444 || ( docker run -d ${DOCKERSELEINUMOPTS} selenium/standalone-firefox && sleep 20 )
nc -vz localhost 4444 || ( docker run -d ${DOCKERSELEINUMOPTS} selenium/standalone-firefox && sleep 20 )
sleep 20

sudo chown -R ubuntu:ubuntu /home/ubuntu ${WORKSPACE} /usr/local/drupal-infrastructure
if [[ ! -d "${WORKSPACE}/build" ]]; then
  mkdir "${WORKSPACE}/build"
fi
sudo chown -R ubuntu:ubuntu ${WORKSPACE}
cd /usr/local/drupal-infrastructure/
git pull --rebase origin master
