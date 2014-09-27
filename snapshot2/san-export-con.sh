#!/bin/bash
set -uex
### start mysql
### create skeleton db
### Drop raw copy of the DB
### stop mysql
DBIMPORT="drupal"
DBEXPORT="drupal_export"
SANTYPE=$1

[ ! -d /var/dumps/${SANTYPE}/td/ ] && mkdir /var/dumps/${SANTYPE}/td/
rm -rf /var/dumps/${SANTYPE}/td/*
service mysql start && \
/media/infrastructure/sanitize/sanitize.sh ${DBIMPORT} ${SANTYPE} $2 && \
mysql -uroot -e "DROP DATABASE IF EXISTS drupal;" && \
mysql -uroot -e "DROP DATABASE IF EXISTS pivots;" && \
mysql -uroot -e "DROP DATABASE IF EXISTS narayan;" && \
mysqldump ${DBEXPORT} d > /var/dumps/${SANTYPE}/td/${DBEXPORT}-tables.sql
mysqldump ${DBEXPORT} --tab=/var/dumps/${SANTYPE}/td/
service mysql stop
rm -rf /var/lib/mysql/*
mysql_install_db


service mysql start
mysql -uroot -e "CREATE DATABASE drupal_export;"

time mysql ${DBEXPORT} < /var/dumps/${SANTYPE}/td/${DBEXPORT}-tables.sql
time mysqlimport -uroot --use-threads=8 ${DBEXPORT}  /var/dumps/${SANTYPE}/td/*.txt

service mysql stop
exit
