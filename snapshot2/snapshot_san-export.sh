#!/bin/bash
set -uex

[ ! -f /etc/dbdump/conf ] && exit 1
source /etc/dbdump/conf

PRODDB="${1}"
DBEXPORT="${2}"
SANTYPE="${3}"
SANOUT="${4}"
SSHUSER=${5}
INFRAREPO=${6}

DATE=$(date +'%Y%m%d%H%M')
JOB_NAME=${JOB_NAME:=db_backup}

[ ! -d  ${MYSQLDEST}/ ] && sudo btrfs sub create ${MYSQLDEST}/
[ ! -d  ${MYSQLDEST}/raw/ ] &&  sudo btrfs sub create ${MYSQLDEST}/raw/
RAWDIR="${MYSQLDEST}/raw/${PRODDB}"
[ ! -d  ${RAWDIR}/ ] && sudo btrfs sub create ${RAWDIR}/

[ ! -d  ${MYSQLDEST}/working/ ] &&  sudo btrfs sub create ${MYSQLDEST}/working/
WORKINGDIR="${MYSQLDEST}/working/${PRODDB}-${SANTYPE}"
[ ! -d  ${WORKINGDIR}/ ] && sudo btrfs sub create ${WORKINGDIR}/

SANDUMPDIR="${FSDEST}/${DBEXPORT}-${SANTYPE}"
[ ! -d  ${SANDUMPDIR}/ ] && sudo btrfs sub create ${SANDUMPDIR}/

[ ! -d  ${MYSQLDEST}/export/ ] &&  sudo btrfs sub create ${MYSQLDEST}/export/
EXPORTDIR="${MYSQLDEST}/export/${DBEXPORT}-${SANTYPE}"
[ ! -d  ${EXPORTDIR}/ ] && sudo btrfs sub create ${EXPORTDIR}/

sudo chown -R ${SSHUSER}:${SSHUSER} ${EXPORTDIR}/
[ -d  ${WORKINGDIR}/ ] && sudo btrfs sub delete ${WORKINGDIR}/
sudo btrfs sub snapshot ${RAWDIR} ${WORKINGDIR}/
sync
docker run -t --rm \
  -v ${WORKINGDIR}/:/var/lib/mysql/ \
  -v ${SANDUMPDIR}/:/var/dumps/ \
  -v ${INFRAREPO}/:${INFRAREPO}/ \
  -v ${TMPSTORE}/:/mnt/tmp/ \
  ${DOCKERCON} \
  ${INFRAREPO}/snapshot2/snapshot_san-export-con.sh ${PRODDB} ${DBEXPORT} ${SANTYPE} ${SANOUT} ${INFRAREPO}
sync

## tar ball the *.txt files with the schema file
if [ ${SANTYPE} == "redacted" ]; then
  cd ${SANDUMP} && tar cfO - --use-compress-program=pbzip2 *.txt ${SANTYPE}-tables.sql > ${SANDUMP}/current-${SANTYPE}.tar.bz2
else
  sudo rsync -avhP --delete ${WORKINGDIR}/ ${EXPORTDIR}/
  RODIR="${MYSQLDEST}/${DBEXPORT}-${SANTYPE}-${DATE}-ro"
  [ ! -d ${RODIR}/ ] && sudo btrfs sub snapshot -r ${EXPORTDIR}/ ${RODIR}/
fi
sudo btrfs sub delete ${WORKINGDIR}
exit
