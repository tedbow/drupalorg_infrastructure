#!/bin/bash -eux

# Name:        command.sh
# Author:      Nick Schuch (nick@myschuch.com)
# Description: Install DrupalCI console to the host.
date
DIR="/opt/drupalci_testbot"

git clone --branch production http://git.drupal.org/project/drupalci_testbot.git $DIR
cd ${DIR}
composer install --prefer-dist --no-progress

bin/box build
chmod 775 ${DIR}/drupalci
ln -s ${DIR}/drupalci /usr/local/bin/drupalci
