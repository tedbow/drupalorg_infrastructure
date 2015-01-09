#!/bin/bash

###snapshot_prod-rsync.sh <PRODDB> <SSHDEST> <SCRIPTDIR>

set -uex
[ ! -f "/etc/dbdump/conf" ] && exit 1
source /etc/dbdump/conf

PRODDB="${1}"
SSHDEST="${2}"
CWD="${3}"
FSDEST="${4}"

DUMPDIR="${PRODDUMPDIR}/${PRODDB}"

rsync -zavhP --delete --exclude-from ${CWD}/rsync-table-exclusions.txt \
  ${DUMPDIR} ${SSHDEST}:${FSDEST}/

