#!/bin/bash -e

############################################
# Use this script to load all containers
############################################

DOCKERREPOSITORY="${1}"

MAINDIR=$(pwd)
echo "** START: $(date) **"
cd ${MAINDIR}

echo $(pwd)

for DB in $(ls) ; do
  ## Parse the DB name from the file name
  DBNAME=$(echo ${DB} | awk -F'_' '{print $1}')
  ## Parse the DATE name from the file name
  DATE=$(echo ${DB} | awk -F'.' '{print $1}' | awk -F'-' '{print $2}')
  echo "  Loading: ${DOCKERREPOSITORY}/${DBNAME}:${DATE}";
  bunzip2 -dc < ${DB} | docker load
  docker tag ${DOCKERREPOSITORY}/${DBNAME}:${DATE} ${DOCKERREPOSITORY}/${DBNAME}:latest

  echo "  ================================================================"
  echo "  ----------  Conatiner ${DOCKERREPOSITORY}/${DBNAME}:${DATE} Loaded"
  echo "  ================================================================"
done

cd ${MAINDIR}
echo "** END: $(date) **"
