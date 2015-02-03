#!/bin/bash

###snapshot_prod-import-staging.sh <PRODDB> <CURRENTDB>

set -uex

[ ! -f /etc/dbdump/conf ] && exit 1
source /etc/dbdump/conf

PRODDB="${1}"
CURRENTDB="${2}" && \
echo "the current db is ${CURRENTDB}"
FSDEST="${3}"

IMPORTDB=$([[ "${CURRENTDB}" == *1 ]] && echo "${CURRENTDB%?}" || echo "${CURRENTDB}1") && \
echo "The importdb is ${IMPORTDB}"

LOCALDIR="${FSDEST}/${PRODDB}" && \
[ ! -d "${LOCALDIR}/" ] && mkdir -p "${LOCALDIR}/"

time mysql -e "DROP DATABASE IF EXISTS  ${IMPORTDB};CREATE DATABASE ${IMPORTDB};" && \
time cat ${LOCALDIR}/*.sql | mysql ${IMPORTDB} && \
time mysqlimport --local  --debug-info --use-threads=5 ${IMPORTDB} ${LOCALDIR}/*.txt && \
DBTABLE="users" && \
time mysql -e "UPDATE ${IMPORTDB}.${DBTABLE} SET mail = CONCAT(MD5(\`${DBTABLE}\`.\`name\`), '@sanitized.invalid') WHERE uid > 0;" && \
time mysql -e "DELETE FROM variable WHERE name LIKE '%key%';" ${IMPORTDB} && \
time mysql -e "UPDATE ${IMPORTDB}.${DBTABLE} SET init = replace( init, 'www.drupal.org/user', 'staging.devdrupal.org/user') WHERE init LIKE 'www.drupal.org/user/%/edit';" ${IMPORTDB} && \
time mysql -e "UPDATE ${IMPORTDB}.${DBTABLE} SET init = replace( init, 'drupal.org/user', 'staging.devdrupal.org/user') WHERE init LIKE 'drupal.org/user/%/edit';" ${IMPORTDB} && \
DBTABLE="bakery_user" && \
time mysql -e "CREATE INDEX uid_index ON ${IMPORTDB}.${DBTABLE} (uid);" ${IMPORTDB} && \
time mysql -e "CREATE INDEX slave_index ON ${IMPORTDB}.${DBTABLE} (slave);" ${IMPORTDB} && \
time mysql -e "CREATE INDEX slave_uid_index ON ${IMPORTDB}.${DBTABLE} (slave_uid);" ${IMPORTDB}
if [ "${PRODDB}" != "drupal_jobs" -a "${PRODDB}" != "drupal_qa" ]; then
  DBTABLE="comment" && \
  time mysql -e "UPDATE ${IMPORTDB}.${DBTABLE} SET mail = CONCAT(MD5(\`${DBTABLE}\`.\`name\`), '@sanitized.invalid');"
fi
echo "DONE"

