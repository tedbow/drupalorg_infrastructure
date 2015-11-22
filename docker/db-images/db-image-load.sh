#!/bin/bash -e

############################################
# Use this script to load all containers
############################################



echo "** START: $(date) **"
sudo bash -c 'echo 3 > /proc/sys/vm/drop_caches'
for DB in $(ls) ; do
  ## Parse the DB name from the file name
  DBNAME=$(echo ${DB} | awk -F'_' '{print $1}')
  ## Parse the DATE name from the file name
  DOCKERREPOSITORY=$(echo ${DB} | awk -F'.' '{print $2}' | awk -F'-' '{print $1}')
  DATE=$(echo ${DB} | awk -F'.' '{print $2}' | awk -F'-' '{print $2}')
  echo "  Loading: ${DOCKERREPOSITORY}/${DBNAME}:${DATE}";
  bunzip2 -dc < ${DB} | docker load
  docker tag -f ${DOCKERREPOSITORY}/${DBNAME}:${DATE} ${DOCKERREPOSITORY}/${DBNAME}:latest

  echo "  ================================================================"
  echo "  ----------  Conatiner ${DOCKERREPOSITORY}/${DBNAME}:${DATE} Loaded"
  echo "  ================================================================"
done
sudo bash -c 'echo 3 > /proc/sys/vm/drop_caches'
echo "** END: $(date) **"
