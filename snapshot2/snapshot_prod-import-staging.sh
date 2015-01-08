#!/bin/bash

###snapshot_prod-import-staging.sh <PRODDB> <CURRENTDB>

set -uex

[ ! -f ${CWD}/conf ] && exit 1
source /etc/dumpdb/conf

PRODDB="${1}"
CURRENTDB="${2}" && \
echo "the current db is ${CURRENTDB}"

IMPORTDB=$([[ "${CURRENTDB}" == *1 ]] && echo "${CURRENTDB%?}" || echo "${CURRENTDB}1") && \
echo "The importdb is ${IMPORTDB}"

LOCALDIR="${FSDEST}/${PRODDB}" && \
[ ! -d "${LOCALDIR}/" ] && mkdir -p "${LOCALDIR}/"

time mysql -e "DROP DATABASE ${IMPORTDB};CREATE DATABASE ${IMPORTDB};" && \
time cat ${LOCALDIR}/*.sql | mysql ${IMPORTDB} && \
time mysqlimport --local  --debug-info --use-threads=5 ${IMPORTDB} ${LOCALDIR}/*.txt && \
DBTABLE="comment" && \
time mysql -e "UPDATE ${IMPORTDB}.${DBTABLE} SET mail = CONCAT(MD5(\`${DBTABLE}\`.\`name\`), '@sanitized.invalid');" && \
DBTABLE="users" && \
time mysql -e "UPDATE ${IMPORTDB}.${DBTABLE} SET mail = CONCAT(MD5(\`${DBTABLE}\`.\`name\`), '@sanitized.invalid');" && \
time mysql -e "DELETE FROM variable WHERE name LIKE '%key%';" ${IMPORTDB} && \
time mysql -e "UPDATE ${IMPORTDB}.${DBTABLE} SET init = replace( init, 'www.drupal.org/user', 'staging.devdrupal.org/user') WHERE init LIKE 'www.drupal.org/user/%/edit';" ${IMPORTDB} && \
time mysql -e "UPDATE ${IMPORTDB}.${DBTABLE} SET init = replace( init, 'drupal.org/user', 'staging.devdrupal.org/user') WHERE init LIKE 'drupal.org/user/%/edit';" ${IMPORTDB} && \
echo "DONE"
