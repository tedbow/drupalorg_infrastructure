#!/bin/bash -e

export HOME="/home/vagrant"

if [ -f /home/vagrant/bdddrupalext/PROVISIONED ];
then
  echo "You seem to have this box already installed - which is a good thing!"
  echo "Documentation can be found in README.md or read on..."
else
  echo 'Defaults        env_keep +="HOME"' >> /etc/sudoers
  echo "Installing and building the all the things..."
  echo "on: $(hostname) with user: $(whoami) home: $HOME"
  apt-get update && apt-get upgrade -y
  apt-get install -y git gawk grep sudo htop python-pip python-dev build-essential vim
  apt-get autoclean && apt-get autoremove -y

  echo "Installing docker"
  curl -sSL get.docker.io | sh 2>&1 | egrep -i -v "Ctrl|docker installed"
  usermod -a -G docker vagrant

  echo "Installing docker-compose"
  pip install docker-compose

  touch PROVISIONED

fi

chown -fR vagrant:vagrant /home/vagrant
echo "Box started up, run *vagrant halt* to stop."
echo
echo "To access the box and run tests, run:"
echo "- vagrant ssh"
