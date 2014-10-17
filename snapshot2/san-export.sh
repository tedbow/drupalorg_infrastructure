#!/bin/bash
set -uex
###
## Snapshot current to raw-${SANTYPE}
## Run docker container that creates ${SANTYPE} db
## rsync the files from raw-${SANTYPE} over to the current-${SANTYPE}
## snapshot current-${SANTYPE} to ${SANTYPE}-$DATE-ro
## delete the raw-${SANTYPE} snapshot
JOB_NAME=${JOB_NAME:=db_backup}
STORAGEEX="${TMPSTORAGE}/mysql"
STORDUMP="${STORAGE}/dumps/${SANTYPE}"
DBEXPORT="drupal_export"
[ -d ${STORAGEEX}/raw-${SANTYPE} ] &&  sudo btrfs sub delete ${STORAGEEX}/raw-${SANTYPE}
sudo btrfs sub snapshot ${STORAGEEX}/current-raw ${STORAGEEX}/raw-${SANTYPE} && \
sync && \
docker run -t --rm \
  -v ${STORAGEEX}/raw-${SANTYPE}/:/var/lib/mysql/ \
  -v ${STORAGE}/dumps/:/var/dumps/ \
  -v ${INFRAREPO}/:/media/infrastructure/ \
  ${DOCKERCON} \
  /media/infrastructure/snapshot2/san-export-con.sh ${SANTYPE} ${SANOUT}
sync

## tar ball the *.txt files with the schema file
if [ ${SANTYPE} == "redacted" ]; then
  cd ${STORDUMP}/td && tar cfO - --use-compress-program=pbzip2 *.txt ${DBEXPORT}-tables.sql > ${STORDUMP}/${JOB_NAME}-${SANTYPE}.tar.bz2
else
  sudo rsync -avhP --delete ${STORAGEEX}/raw-${SANTYPE}/ ${STORAGE}/mysql/current-${SANTYPE}/
  [ ! -d ${STORAGE}/mysql/${SANTYPE}-$DATE-ro ] && \
    sudo btrfs sub snapshot -r ${STORAGE}/mysql/current-${SANTYPE} ${STORAGE}/mysql/${SANTYPE}-${DATE}-ro
fi
sudo btrfs sub delete ${STORAGEEX}/raw-${SANTYPE}
exit
