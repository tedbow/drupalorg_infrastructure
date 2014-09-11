#!/bin/bash
set -uex
RAWDB="drupal"
### start mysql
### create skeleton db
### Drop raw copy of the DB
### stop mysql
service mysql start && \
/media/infrastructure/sanitize/sanitize.sh drupal skeleton no-dump && \
mysql -uroot -e "DROP DATABASE IF EXISTS drupal;"
mysql -uroot -e "DROP DATABASE IF EXISTS pivots;"
mysql -uroot -e "DROP DATABASE IF EXISTS narayan;"
service mysql stop
exit

