#!/bin/bash
set -uex
STORAGE="/mnt/storage"
INFRAREPO="/mnt/storage/git-repos/infrastructure"
###
## Snapshot current to raw-skel
## Run docker container that creates skeleton db
## rsync the files from raw-skel over to the current-skel
## snapshot current-skel to skel-$DATE-ro
## delete the raw-skel snapshot

DATE=$(date +'%Y%m%d')
[ ! -d ${STORAGE}/mysql/raw-skel ] && \
  sudo btrfs sub snapshot ${STORAGE}/mysql/current-raw ${STORAGE}/mysql/raw-skel
sync
docker run -i -t --rm \
  -v ${STORAGE}/dumps/:/var/dumps/ \
  -v ${STORAGE}/mysql/raw-skel/:/var/lib/mysql/ \
  -v ${INFRAREPO}/:/mnt/infrastructure/ \
  isntall/centos6:mariadb.aria.imp \
  /mnt/infrastructure/snapshot2/skel-export-con.sh
sudo rsync -avhP --delete ${STORAGE}/mysql/raw-skel/ ${STORAGE}/mysql/current-skel/
[ ! -d ${STORAGE}/mysql/skel-$DATE-ro ] && \
  sudo btrfs sub snapshot -r ${STORAGE}/mysql/current-skel ${STORAGE}/mysql/skel-$DATE-ro
sudo btrfs sub delete ${STORAGE}/mysql/raw-skel

