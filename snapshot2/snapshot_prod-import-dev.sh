#!/bin/bash
set -uex

[ ! -f /etc/dbdump/conf ] && exit 1
source /etc/dbdump/conf
PRODDB="${1}"
FSDEST="${2}"
SSHUSER="${3}"
RAWDUMP="${FSDEST}/${PRODDB}"

RAWMYSQL="${MYSQLDEST}/raw/${PRODDB}/"

sudo chown -R ${SSHUSER}:${SSHUSER} ${RAWDUMP}/
[ ! -d "${DEVDEST}/current-${PRODDB}" ] && sudo btrfs sub create ${DEVDEST}/current-${PRODDB}
sudo chown -R ${SSHUSER}:${SSHUSER} ${RAWMYSQL}

docker run -t --rm \
  -v ${RAWDUMP}/:/mnt/ \
  -v ${RAWMYSQL}/:/var/lib/mysql/ \
  -v ${INFRAREPO}/:${INFRAREPO}/ \
  ${DOCKERCON} \
  ${INFRAREPO}/snapshot2/snapshot_prod-import-dev-con.sh ${PRODDB} "/mnt" ${NTHREADS}
sync