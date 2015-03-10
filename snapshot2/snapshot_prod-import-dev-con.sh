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
time cat ${TXTTABLEDIR}/${PRODDB}-schema.sql | mysql ${PRODDB}
time lz4cat ${TXTTABLEDIR}/${PRODDB}-data.sql.lz4 | mysql ${PRODDB}
service mysql stop
exit
