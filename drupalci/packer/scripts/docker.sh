#!/bin/bash -eux

# Name:        docker.sh
# Author:      Nick Schuch (nick@myschuch.com)
# Description: Installs Docker.
date
curl -sSL https://get.docker.com/ | sed 's/docker-engine/docker-engine_1.12.1-0~trusty_amd64.deb/' |sudo sh

# We also need to add the "ubuntu" user to the docker group so it can run
# containers.
usermod -a -G docker ubuntu

service docker stop
echo 'DOCKER_OPTS=" -s devicemapper"' >> /etc/default/docker
rm -rf /var/lib/docker/*
service docker start

