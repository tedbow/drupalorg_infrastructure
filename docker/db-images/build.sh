#!/bin/bash -e

############################################
# Use this script to recreate all containers
############################################

IMAGE=mariadb
TAG=10.0
DBUSER=root
DBPASS=drupal
BASEDIR=$HOME
DATE=$(date +'%Y%m%d%H%M')
MYSQLCONF="--datadir=/mnt --max-allowed-packet=256M --innodb-log-file-size=1G --innodb-file-per-table=1 --innodb-file-format=barracuda"
MYSQLPORT="3306"
DOCKERREPOSITORY="devwww"
SLEEPTIME="10"

### Change only above this line ####

MAINDIR=$(pwd)
echo "** START: $(date) **"
cd ${MAINDIR}

echo $(pwd)

for DB in $(ls) ; do
  DBNAME=$(echo ${DB} | awk -F'_' '{print $1}')

  echo "Building: ${DBNAME}";

  echo "  Starting new Mariadb container"
  CONTAINERID=$(docker run -e MYSQL_ROOT_PASSWORD=${DBPASS} -d ${IMAGE}:${TAG} ${MYSQLCONF})

  #### Get container IP
  IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "${CONTAINERID}")
  echo "  Container IP: ${IP}"

  echo "  Letting MYSQL spin up"
  sleep ${SLEEPTIME}
  nc -z ${IP} ${MYSQLPORT} || sleep ${SLEEPTIME}
  nc -z ${IP} ${MYSQLPORT} || sleep ${SLEEPTIME}

  echo "  Creating DB: ${DBNAME}"
  mysql -u ${DBUSER} -p${DBPASS} -h ${IP} -P ${MYSQLPORT} -e "CREATE DATABASE ${DBNAME}"

  echo "  Import data into database"
  bunzip2 < ${DBNAME}_database_snapshot.dev-current.sql.bz2 | mysql -u ${DBUSER} -p${DBPASS} -h ${IP} -P ${MYSQLPORT} ${DBNAME}

  echo "  Stoping container with ID: ${CONTAINERID}"
  docker stop ${CONTAINERID}

  echo "  Committing container"
  docker commit -m="${DBNAME}-${DATE}" ${CONTAINERID} ${DOCKERREPOSITORY}/${DBNAME}:latest
  docker tag ${DOCKERREPOSITORY}/${DBNAME}:latest ${DOCKERREPOSITORY}/${DBNAME}:${DATE}

  echo "  Removing container"
  docker rm ${CONTAINERID}

  echo "  ================================================================"
  echo "  ----------  Conatiner ${DOCKERREPOSITORY}/${DBNAME}:${DATE} created"
  echo "  ================================================================"
done

cd ${MAINDIR}
echo "** END: $(date) **"
