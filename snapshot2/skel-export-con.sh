#!/bin/bash
set -uex

### start mysql
### create skeleton db
### Drop raw copy of the DB
### stop mysql
service mysql start
/mnt/infrastructure/sanitize/sanitize.sh raw_import skeleton no-dump
mysql -uroot -e "DROP DATABASE IF EXISTS raw_import;"
service mysql stop

