#!/bin/bash
set -uex
### start mysql
### create skeleton db
### Drop raw copy of the DB
### stop mysql
DBIMPORT="drupal"
SANTYPE=$1
service mysql start && \
/media/infrastructure/sanitize/sanitize.sh ${DBIMPORT} ${SANTYPE} $2 && \
mysql -uroot -e "DROP DATABASE IF EXISTS drupal;" && \
mysql -uroot -e "DROP DATABASE IF EXISTS pivots;" && \
mysql -uroot -e "DROP DATABASE IF EXISTS narayan;" && \
service mysql stop
rm -rf /var/lib/mysql/*
mysql_install_db
pbunzip2 -f /var/dumps/${SANTYPE}/db_backup.${SANTYPE}-current.sql.bz2 > /var/dumps/${SANTYPE}/db_backup.${SANTYPE}-current.sql
service mysql start
mysql -uroot -e "CREATE DATABASE drupal_export;"
mysql -uroot drupal_export < /var/dumps/${SANTYPE}/db_backup.${SANTYPE}-current.sql
service mysql stop
exit

