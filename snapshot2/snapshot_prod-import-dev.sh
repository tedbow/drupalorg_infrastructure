#!/bin/bash
set -uex

[ ! -f /etc/dbdump/conf ] && exit 1
source /etc/dbdump/conf
PRODDB="${1}"
FSDEST="${2}"
SSHUSER="${3}"
RAWDUMP="${FSDEST}/${PRODDB}"
sudo chown -R ${SSHUSER}:${SSHUSER} ${RAWDUMP}/

docker run -t --rm \
  -v ${RAWDUMP}/:/mnt/ \
  -v${DEVDEST}:/var/lib/mysql/ \
  -v ${INFRAREPO}/:/media/infrastructure/ \
  ${DOCKERCON} \
  /media/infrastructure/snapshot2/snapsho_prod-import-con.sh ${PRODB} "/mnt" ${NTHREADS}
sync
