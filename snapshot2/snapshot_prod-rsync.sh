/bin/bash

set -uex
PRODDB="${1}"
DUMPDIR="${2}/${PRODDB}"
DESTINATIONDUMP="${3}"
SSHUSER=$"{4}"
rsync -zavhP --delete --exclude-from ${CWD}/rsync-table-exclusions.txt \
  ${DUMPDIR} ${SSHUSER}@{$SSHDESTINATIONDUMP}:${DESTINATIONDUMP}/

