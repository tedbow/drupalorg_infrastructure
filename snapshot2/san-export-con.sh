#!/bin/bash
set -uex
### start mysql
### create skeleton db
### Drop raw copy of the DB
### stop mysql
DBIMPORT="drupal"
DBEXPORT="drupal_export"
SANTYPE=$1
DUMPDIR="/var/dumps/${SANTYPE}/td"
[ ! -d ${DUMPDIR}/ ] && mkdir ${DUMPDIR}/ || rm -rf ${DUMPDIR}/*
chown -R mysql:mysql /var/lib/mysql/
service mysql start && \
/media/infrastructure/sanitize/sanitize.sh ${DBIMPORT} ${SANTYPE} $2
mysqldump ${DBEXPORT} --tab=${DUMPDIR}/
service mysql stop
rm -rf /var/lib/mysql/*
cp /etc/my-ariadb.cnf /etc/my.cnf
mysql_install_db
service mysql start
service mysql status
mysql -uroot -e "CREATE DATABASE ${DBEXPORT};"
time cat ${DUMPDIR}/*.sql | mysql ${DBEXPORT}
time mysqlimport -uroot --debug-info --use-threads=4 ${DBEXPORT}  ${DUMPDIR}/*.txt
service mysql stop
exit

