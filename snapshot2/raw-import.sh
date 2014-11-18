#!/bin/bash
set -uex
## set DATE var
BINVARS=" --parallel=${RTHREADS} --compress --compress-threads=${RTHREADS} --defaults-file=/etc/my.cnf --no-lock  --ibbackup=${XBV} "
sudo chown -R ec2:ec2 ${TMPSTORAGE}/mysql/current-raw/
sudo rm -rf ${TMPSTORAGE}/mysql/current-raw/*
ssh ec2@db2-static.drupal.org "~/binback.sh ${SSHTARGET} ${TMPSTORAGE} ${BINVARS} "
docker run -t --rm \
  -v ${TMPSTORAGE}/mysql/current-raw/:/var/lib/mysql/ \
  -v ${INFRAREPO}/:/media/infrastructure/ \
  ${DOCKERCON} \
  /media/infrastructure/snapshot2/raw-import-con.sh ${NTHREADS}
#[ ! -d ${STORAGE}/mysql/current-raw-$DATE-ro ] && \
#sudo btrfs sub snapshot -r ${STORAGE}/mysql/current-raw ${STORAGE}/mysql/raw-$DATE-ro
sync

