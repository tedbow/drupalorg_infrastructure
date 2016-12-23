#!/bin/bash -eux

# Name:        containers.sh
# Author:      Nick Schuch (nick@myschuch.com)
# Description: Pull down the containers required for a build via the make command.
date
cd /opt/drupalci_testbot
# TODO: this should get the containers from drupalci/* and not from the local filesystem.
for CONTAINER in $(find ./containers -name Dockerfile | grep -v 'dev' | awk -F"/" '{print $4}');
do
    docker pull drupalci/${CONTAINER};
done
