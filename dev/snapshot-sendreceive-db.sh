#!/bin/bash

set -uex

DBDUMPCONF="/etc/dbdump/conf"
SSTYPE="${1}"
[ ! -d "${DBDUMPCONF}" ] && source "${DBDUMPCONF}" || exit 1

### Get the name of the parent on the FileSystemDestinationDirectory
DESTPARENT="$(cd ${SSDESTSUBVOL} && ls | grep "${SSTYPE}"  | sort | tail -n 1)"

#### OGPARENT="$(cd ${SSORIGSUBVOL} && ls | grep "${SSTYPE}"  | sort | tail -n 2 | head)"
OGCHILD="$(cd ${SSORIGSUBVOL} &&ls | grep "${SSTYPE}"  | sort | tail -n 1)"
NEWSS="${SSORIGSUBVOL}/${OGCHILD}"

### check if SS already exists
[ -d "${SSDESTSUBVOL}/${OGCHILD}" ] && echo "Dir ${SSDESTSUBVOL}/${OGCHILD} already exists" && exit 0

### Verify that the DESTPARENT exists onf the FS OG
## check to see if there is a DESTPARENT
[ -z "${DESTPARENT}" ] && time sudo btrfs send ${NEWSS} | sudo btrfs receive ${SSDESTSUBVOL}/ && exit 0
## verify that the DESTPARENT exists on the FSORIG
[ -d "${SSORIGSUBVOL}/${DESTPARENT}" ] || ( echo "The parent does not exist on the originating file system" && exit 1 )
## find closest relative on dest dir
time sudo btrfs send -p "${SSORIGSUBVOL}/${DESTPARENT}" "${NEWSS}" | sudo btrfs receive ${SSDESTSUBVOL}/
