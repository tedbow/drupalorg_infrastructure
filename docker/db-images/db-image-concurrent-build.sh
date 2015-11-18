#!/bin/bash


DUMPSDIR="/var/dumps"
## Strings to ignore, like the raw dumps
IGNORE="raw|qa|latinamerica2015|association_civicrm"
DBSTRING="sql"
CONCURRENCY="3"
export SCRIPTDIR=$(pwd)
export DATE=$(date +'%Y%m%d%H%M')


echo "Drop linux caches"
echo 3 > /proc/sys/vm/drop_caches

cd ${DUMPSDIR}
find -type l | grep -Ev ${IGNORE} | grep ${DBSTRING} | awk -F'/' '{print $2 " " $3}' | xargs -P ${CONCURRENCY} -I {} -i bash -c  '${SCRIPTDIR}/db-image-build.sh ${DATE} {}'
