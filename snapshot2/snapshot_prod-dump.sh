#!/bin/bash

set -uex

[ ! -f /etc/dbdump/conf ] && exit 1
source /etc/dbdump/conf

PRODDB="${1}"
CWD="${2}"
DUMPDIR="${PRODDUMPDIR}/${PRODDB}"
TMPPREFIX="/tmp/${PRODDB}"
echo "" > ${TMPPREFIX}-ignore
EXCLUSIONFILE="${CWD}/table-exclusions.txt"
[ ! -d "${DUMPDIR}/" ] && mkdir -p "${DUMPDIR}/"
rm -f ${DUMPDIR}/*

while read LINE
do
  TABLENAME=$(mysql -N -e "show tables like  '$LINE' ;"  ${PRODDB} )
  [ ! -z "${TABLENAME}" ] && echo "${TABLENAME}" | while read LINE2
  do
    echo -n "--ignore-table=${PRODDB}.${LINE2} " >> ${TMPPREFIX}-ignore
  done
done < ${EXCLUSIONFILE}
EXCLUDEDTABLES="$(cat ${TMPPREFIX}-ignore)"
mysqldump ${PRODDB} --no-data > ${DUMPDIR}/${PRODDB}-schema.sql
mysqldump ${PRODDB} ${EXCLUDEDTABLES} --single-transaction --no-create-db --no-create-info --max_allowed_packet=128M | lz4 > ${DUMPDIR}/${PRODDB}-data.sql.lz4
