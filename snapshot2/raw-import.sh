#!/bin/bash
set -uex
## set DATE var
sudo chown -R ${SSHUSER}:${SSHUSER} ${TMPSTORAGE}/mysql/current-raw/
sudo rm -rf ${TMPSTORAGE}/mysql/current-raw/*
ssh ${SSHUSER}@${SSHORIGTARGET} "/usr/local/drupal-infrastructure/snapshot2/binback.sh \
  ${SSHTARGET} ${TMPSTORAGE} ${BINVARS} "
docker run -t --rm \
  -v ${TMPSTORAGE}/mysql/current-raw/:/var/lib/mysql/ \
  -v ${INFRAREPO}/:/media/infrastructure/ \
  ${DOCKERCON} \
  /media/infrastructure/snapshot2/raw-import-con.sh ${NTHREADS}
#[ ! -d ${STORAGE}/mysql/current-raw-$DATE-ro ] && \
#sudo btrfs sub snapshot -r ${STORAGE}/mysql/current-raw ${STORAGE}/mysql/raw-$DATE-ro
sync

