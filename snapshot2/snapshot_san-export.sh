#!/bin/bash
set -uex

[ ! -f /etc/dbdump/conf ] && exit 1
source /etc/dbdump/conf

PRODDB="${1}"
DBEXPORT="${2}"
SANTYPE="${3}"
SANOUT="${4}"

DATE=$(date +'%Y%m%d%H%M')
JOB_NAME=${JOB_NAME:=db_backup}
SSHUSER=$(whoami)
RAWDIR="${MYSQLDEST}/raw/${PRODDB}"
WORKINGDIR="${MYSQLDEST}/working/${PRODDB}-${SANTYPE}"
SANDUMPDIR="${FSDEST}/${DBEXPORT}-${SANTYPE}"
EXPORTDIR="${MYSQLDEST}/export/${DBEXPORT}-${SANTYPE}"
RODIR="${MYSQLDEST}/${DBEXPORT}-${SANTYPE}-${DATE}-ro"
[ ! -d  ${EXPORTDIR}/ ] &&  sudo btrfs sub create ${EXPORTDIR}/
sudo chown -R ${SSHUSER}:${SSHUSER} ${EXPORTDIR}/
[ -d  ${WORKINGDIR}/ ] &&  sudo btrfs sub delete ${WORKINGDIR}/
sudo btrfs sub snapshot ${RAWDIR} ${WORKINGDIR}/ && \
sync && \
docker run -t --rm \
  -v ${WORKINGDIR}/:/var/lib/mysql/ \
  -v ${SANDUMPDIR}/:/var/dumps/ \
  -v ${INFRAREPO}/:${INFRAREPO}/ \
  ${DOCKERCON} \
  ${INFRAREPO}/snapshot2/snapshot_san-export-con.sh ${PRODDB} ${DBEXPORT} ${SANTYPE} ${SANOUT} ${INFRAREPO}
sync

## tar ball the *.txt files with the schema file
if [ ${SANTYPE} == "redacted" ]; then
  cd ${SANDUMP} && tar cfO - --use-compress-program=pbzip2 *.txt ${SANTYPE}-tables.sql > ${SANDUMP}/current-${SANTYPE}.tar.bz2
else
  sudo rsync -avhP --delete ${WORKINGDIR}/ ${EXPORTDIR}/
  [ ! -d ${RODIR}/ ] && \
  sudo btrfs sub snapshot -r ${EXPORTDIR}/ ${RODIR}/
fi
sudo btrfs sub delete ${WORKINGDIR}
exit
