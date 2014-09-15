#!/bin/bash
set -uex
## set DATE var
DATE=$(date +'%Y%m%d')
BINVARS=" --parallel=${RTHREADS} --compress --compress-threads=${RTHREADS} --defaults-file=/etc/my.cnf --no-lock  --ibbackup=${XBV} "
sudo chown -R ec2:ec2 ${STORAGE}/mysql/current-raw/
sudo rm -rf ${STORAGE}/mysql/current-raw/*
ssh ec2@db2-static.drupal.org ~/binback.sh ${STORAGE} ${BINVARS} 
#sudo btrfs sub snapshot -r ${STORAGE}/mysql/current-raw ${STORAGE}/mysql/raw-bin-${DATE}-ro
docker run -t --rm \
  -v ${STORAGE}/mysql/current-raw/:/var/lib/mysql/ \
  -v ${INFRAREPO}/:/media/infrastructure/ \
  ${DOCKERCON} \
  /media/infrastructure/snapshot2/raw-import-con.sh ${NTHREADS}
#[ ! -d ${STORAGE}/mysql/current-raw-$DATE-ro ] && \
#sudo btrfs sub snapshot -r ${STORAGE}/mysql/current-raw ${STORAGE}/mysql/raw-$DATE-ro
sync

