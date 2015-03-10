#!/bin/bash
set -uex

[ ! -f /etc/dbdump/conf ] && exit 1
source /etc/dbdump/conf
PRODDB="${1}"
FSDEST="${2}"
SSHUSER="${3}"
TXTTABLEDIR="${FSDEST}/${PRODDB}"

[ ! -d  ${MYSQLDEST}/ ] && sudo btrfs sub create ${MYSQLDEST}/
[ ! -d  ${MYSQLDEST}/raw/ ] && sudo btrfs sub create ${MYSQLDEST}/raw/
RAWMYSQL="${MYSQLDEST}/raw/${PRODDB}/"
[ ! -d  ${RAWMYSQL}/ ] && sudo btrfs sub create ${RAWMYSQL}/

sudo chown -R ${SSHUSER}:${SSHUSER} ${TXTTABLEDIR}/
sudo chown -R ${SSHUSER}:${SSHUSER} ${RAWMYSQL}

docker run -t --rm \
  -v ${TXTTABLEDIR}/:/mnt/ \
  -v ${RAWMYSQL}/:/var/lib/mysql/ \
  -v ${INFRAREPO}/:${INFRAREPO}/ \
  ${DOCKERCON} \
  ${INFRAREPO}/snapshot2/snapshot_prod-import-dev-con.sh ${PRODDB} "/mnt" ${NTHREADS}
sync
