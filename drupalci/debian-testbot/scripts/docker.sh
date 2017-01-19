#!/bin/bash -eux

# Name:        docker.sh
# Author:      Nick Schuch (nick@myschuch.com)
# Description: Installs Docker.
date
apt-cache show docker-engine |grep Filename
curl -sSL https://get.docker.com/ | sed 's/docker-engine/docker-engine=1.12.1-0~jessie/' |sudo sh

# We also need to add the "admin" user to the docker group so it can run
# containers.
usermod -a -G docker admin

service docker stop
echo 'DOCKER_OPTS=" -s devicemapper"' >> /etc/default/docker
rm -rf /var/lib/docker/*
service docker start

