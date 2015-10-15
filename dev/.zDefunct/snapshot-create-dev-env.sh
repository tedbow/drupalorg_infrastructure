#!/bin/bash

set -uex

DBDUMPCONF="/etc/dbdump/conf"
SSTYPE="${1}"
DATE="$(date +'%Y%m%d%H%M')"
[ ! -d "${DBDUMPCONF}" ] && source "${DBDUMPCONF}" || exit 1

## Create new d.o php



## Get new db and container
### Get the name of the parent on the FileSystemDestinationDirectory
CURRENTDB="$(cd ${SSDESTSUBVOL} && ls | grep "${SSTYPE}"  | sort | tail -n 1)"

time sudo sh -c "btrfs subvolume snapshot \"${SSDESTSUBVOL}/${CURRENTDB}\" \"${SSDESTSUBVOL}/${SSTYPE}-${DATE}\" "
docker run -d -t --name="${SSTYPE}-${DATE}" -v ${SSDESTSUBVOL}/${SSTYPE}-${DATE}:/var/lib/mysql --expose=3306 ${DOCKERCON} sh -c "cp /etc/my-ariadb.cnf /etc/my.cnf && service mysql start && bash "
docker inspect "${SSTYPE}-${DATE}" | grep "IPAddress"
