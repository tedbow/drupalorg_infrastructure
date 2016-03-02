#!/bin/bash

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Copy data from db5/db6 and move it into place before running sanitization
sudo systemctl stop mysql
sudo systemctl status mysql || true
sudo killall mysqld || true
sudo rm -rf /var/lib/mysql/
sudo systemctl stop puppet
sudo systemctl status puppet || true
time ssh bender@db6-reader-vip.drupal.org
time innobackupex --parallel=2 --compress-threads=4 --decompress /var/sanitize/drupal_sanitize/
time innobackupex --apply-log --use-memory=6G /var/sanitize/drupal_sanitize/
sudo rm -rf /var/lib/mysql/
time sudo innobackupex --parallel=8 --move-back /var/sanitize/drupal_sanitize/
sudo chown -R mysql:mysql /var/lib/mysql
sudo systemctl start mysql
sudo systemctl status mysql || true
sudo systemctl start puppet
sudo systemctl status puppet || true
