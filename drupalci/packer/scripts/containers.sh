#!/bin/bash -eux

# Name:        containers.sh
# Author:      Nick Schuch (nick@myschuch.com)
# Description: Pull down the containers required for a build via the make command.
date
cd /opt/drupalci_testbot
docker pull drupalci/mysql-5.5
docker pull drupalci/pgsql-9.1
docker pull drupalci/web-7
docker pull drupalci/web-5.6
docker pull drupalci/web-5.5
docker pull drupalci/web-5.4
docker pull drupalci/web-5.3

# TODO: this should iterate over containers that are matchable by a docker search - need a good naming scheme for the
# new containers.
#for CONTAINER in $(find ./containers -name Dockerfile | grep -v 'dev' | awk -F"/" '{print $4}');
#do
#   docker pull drupalci/${CONTAINER};
#done
