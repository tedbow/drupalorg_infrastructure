#!/bin/bash
set -uex
###
## Snapshot current to raw-skel
## Run docker container that creates skeleton db
## rsync the files from raw-skel over to the current-skel
## snapshot current-skel to skel-$DATE-ro
## delete the raw-skel snapshot

DATE=$(date +'%Y%m%d')
[ -d ${STORAGE}/mysql/raw-skeleton ] &&  sudo btrfs sub delete ${STORAGE}/mysql/raw-skeleton
sudo btrfs sub snapshot ${STORAGE}/mysql/current-raw ${STORAGE}/mysql/raw-skeleton && \
sync && \
docker run -t --rm \
  -v ${STORAGE}/dumps/:/var/dumps/ \
  -v ${STORAGE}/mysql/raw-skeleton/:/var/lib/mysql/ \
  -v ${INFRAREPO}/:/media/infrastructure/ \
  ${DOCKERCON} \
  /media/infrastructure/snapshot2/skel-export-con.sh

sudo rsync -avhP --delete ${STORAGE}/mysql/raw-skeleton/ ${STORAGE}/mysql/current-skeleton/
[ ! -d ${STORAGE}/mysql/skeleton-$DATE-ro ] && \
  sudo btrfs sub snapshot -r ${STORAGE}/mysql/current-skeleton ${STORAGE}/mysql/skeleton-$DATE-ro
sudo btrfs sub delete ${STORAGE}/mysql/raw-skeleton
exit

