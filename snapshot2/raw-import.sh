#!/bin/bash
set -uex
## set DATE var
DATE=$(date +'%Y%m%d')
STORAGE="/mnt/storage"
INFRAREPO=""${STORAGE}/git-repos/infrastructure
## get file
## decompreses
###
## run docker contain that
## is connected to dumps/raw and the new subvol
### install new db
### imports the db
### run san script (for skeleton atm)
## create new subvolume
rsync -LavhP isntall@util.drupal.org:/var/dumps/raw/drupal_database_snapshot.raw-current.sql.bz2 ${STORAGE}/dumps/raw/
cd ${STORAGE}/dumps/raw/ && \
lbunzip2 -f drupal_database_snapshot.raw-current.sql.bz2
docker run -i -t --rm \
  -v ${STORAGE}/dumps/:/var/dumps/ \
  -v ${STORAGE}/mysql/current-raw/:/var/lib/mysql/ \
  -v ${INFRAREPO}/:/mnt/infrastructure/ \
  isntall/centos6-mariadb.aria.imp \
  /mnt/infrastructure/snapshot2/raw-import-con.sh
[ ! -d ${STORAGE}/mysql/raw-$DATE-ro ] && \
sudo btrfs sub snapshot -r ${STORAGE}/mysql/current-raw ${STORAGE}/mysql/raw-$DATE-ro
sync

