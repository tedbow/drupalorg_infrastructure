#!/bin/bash

###snapshot_prod-import-staging.sh <PRODDB> <CURRENTDB>

set -uex

PRODDB="${1}"
TXTTABLEDIR="${2}"
NTHREADS="${3}"

mysql_install_db
service mysql start
service mysql status
mysql -uroot -e "CREATE DATABASE ${PRODDB};"
time cat ${TXTTABLEDIR}/*.sql | mysql ${PRODDB}
time mysqlimport -uroot --debug-info --use-threads=${NTHREADS} ${PRODDB}  ${TXTTABLEDIR}/*.txt
service mysql stop
exit
