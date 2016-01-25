#!/bin/bash

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Delete any data from /var/lib/mysql and install an empty database
sudo systemctl stop mysql
sudo systemctl status mysql
sudo killall mysqld
sudo rm -rf /var/lib/mysql/
sudo systemctl stop puppet
sudo systemctl status puppet
sudo -u mysql mysql_install_db
sudo chown -R mysql:mysql /var/lib/mysql
sudo systemctl start mysql
sudo systemctl status mysql
sudo systemctl start puppet
sudo systemctl status puppet

