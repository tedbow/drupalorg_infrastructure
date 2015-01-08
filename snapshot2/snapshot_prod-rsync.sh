#!/bin/bash

###snapshot_prod-rsync.sh <PRODDB> <SSHSTAGING> <SCRIPTDIR>

set -uex
[ ! -f ${CWD}/conf ] && exit 1
source /etc/dumpdb/conf

DUMPDIR="${PRODDUMPDIR}/${PRODDB}"
DESTINATIONDUMP="${STAGINGDEST}/${PRODDB}"


PRODDB="${1}"
SSHSTAGING="${2}"
CWD="${3}"

rsync -zavhP --delete --exclude-from ${CWD}/rsync-table-exclusions.txt \
  ${DUMPDIR} ${SSHSTAGING}:${DESTINATIONDUMP}/

