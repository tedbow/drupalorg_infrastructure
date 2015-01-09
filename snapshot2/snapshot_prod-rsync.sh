#!/bin/bash

###snapshot_prod-rsync.sh <PRODDB> <SSHDEST> <SCRIPTDIR>

set -uex
[ ! -f "/etc/dbdump/conf" ] && exit 1
source /etc/dbdump/conf

DUMPDIR="${PRODDUMPDIR}/${PRODDB}"
DESTDUMP="${FSDEST}/${PRODDB}"


PRODDB="${1}"
SSHDEST="${2}"
CWD="${3}"

rsync -zavhP --delete --exclude-from ${CWD}/rsync-table-exclusions.txt \
  ${DUMPDIR} ${SSHDEST}:${DESTDUMP}/

