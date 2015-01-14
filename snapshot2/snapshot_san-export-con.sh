#!/bin/bash
set -uex
### start mysql
### create skeleton db
### Drop raw copy of the DB
### stop mysql
PRODDB="${1}"
DBEXPORT="${2}"
SANTYPE="${3}"
SANOUT="${4}"
INFRAREPO="${5}"

DUMPDIR="/var/dumps/${DBEXPORT}-${SANTYPE}/td"
chmod -R 777 ${DUMPDIR}/
[ ! -d ${DUMPDIR}/ ] && mkdir -p ${DUMPDIR}/ || rm -rf ${DUMPDIR}/*
chown -R mysql:mysql /var/lib/mysql/
service mysql start && \
${INFRAREPO}/sanitize/sanitize.sh ${PRODDB} ${SANTYPE} ${SANOUT}
mysqldump ${DBEXPORT} --single-transaction --tab=${DUMPDIR}/
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
