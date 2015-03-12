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

DUMPDIR="/mnt/tmp/${DBEXPORT}-${SANTYPE}"
[ ! -d ${DUMPDIR}/ ] && mkdir -p ${DUMPDIR}/
chmod -R 777 ${DUMPDIR}/
rm -rf ${DUMPDIR}/*
chown -R mysql:mysql /var/lib/mysql/
service mysql start && \
${INFRAREPO}/sanitize/sanitize.sh ${PRODDB} ${SANTYPE} ${SANOUT}
mysqldump ${DBEXPORT} --single-transaction | lz4 > ${DUMPDIR}/${DBEXPORT}-${SANTYPE}.sql.lz4
service mysql stop
rm -rf /var/lib/mysql/*
cp /etc/my-ariadb.cnf /etc/my.cnf
mysql_install_db
service mysql start
service mysql status
mysql -uroot -e "CREATE DATABASE ${DBEXPORT};"
time lz4cat ${DUMPDIR}/${DBEXPORT}-${SANTYPE}.sql.lz4 | mysql ${DBEXPORT}
service mysql stop
exit
