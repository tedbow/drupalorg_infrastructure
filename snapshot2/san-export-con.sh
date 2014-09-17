#!/bin/bash
set -uex
### start mysql
### create skeleton db
### Drop raw copy of the DB
### stop mysql
DBIMPORT="drupal"
service mysql start && \
/media/infrastructure/sanitize/sanitize.sh ${DBIMPORT} $1 $2 && \
mysql -uroot -e "DROP DATABASE IF EXISTS drupal;"
mysql -uroot -e "DROP DATABASE IF EXISTS pivots;"
mysql -uroot -e "DROP DATABASE IF EXISTS narayan;"
service mysql stop
exit

