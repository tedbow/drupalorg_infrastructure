#!/bin/bash

# upgrading and updating
apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get clean
apt-get autoclean
apt-get -y autoremove
