#!/bin/bash -eux

date
curl -sSL https://get.docker.com/ | sudo sh

# We also need to add the "ubuntu" user to the docker group so it can run
# containers.
usermod -a -G docker ubuntu

service docker stop
echo 'DOCKER_OPTS=" -s devicemapper"' >> /etc/default/docker
rm -rf /var/lib/docker/*
service docker start
