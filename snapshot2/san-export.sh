#!/bin/bash
set -uex
###
## Snapshot current to raw-${SANTYPE}
## Run docker container that creates ${SANTYPE} db
## rsync the files from raw-${SANTYPE} over to the current-${SANTYPE}
## snapshot current-${SANTYPE} to ${SANTYPE}-$DATE-ro
## delete the raw-${SANTYPE} snapshot
STORAGEEX="${TMPSTORAGE}/mysql"
[ -d ${STORAGEEX}/raw-${SANTYPE} ] &&  sudo btrfs sub delete ${STORAGEEX}/raw-${SANTYPE}
sudo btrfs sub snapshot ${STORAGEEX}/current-raw ${STORAGEEX}/raw-${SANTYPE} && \
sync && \
docker run -t --rm \
  -v ${STORAGEEX}/raw-${SANTYPE}/:/var/lib/mysql/ \
  -v ${INFRAREPO}/:/media/infrastructure/ \
  ${DOCKERCON} \
  /media/infrastructure/snapshot2/san-export-con.sh ${SANTYPE} ${SANOUT}
sudo rm ${STORAGEEX}/raw-${SANTYPE}/xtrabackup_*
sync
sudo rsync -avhP --delete ${STORAGEEX}/raw-${SANTYPE}/ ${STORAGE}/mysql/current-${SANTYPE}/
[ ! -d ${STORAGE}/mysql/${SANTYPE}-$DATE-ro ] && \
  sudo btrfs sub snapshot -r ${STORAGE}/mysql/current-${SANTYPE} ${STORAGE}/mysql/${SANTYPE}-${DATE}-ro
sudo btrfs sub delete ${STORAGEEX}/raw-${SANTYPE}
exit

