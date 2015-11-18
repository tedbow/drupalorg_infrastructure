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
DOCKERREPOSITORY="${1}"
DUMPSDIR="/var/dumps"
SLEEPTIME="10"
IGNORE="qa|latinamerica2015|association_civicrm"
CURRENTSTRINGSQL="_database_snapshot.${DOCKERREPOSITORY}-current.sql.bz2"
CURRENTSTRINGIMAGE="_database_snapshot.${DOCKERREPOSITORY}-current.image.tar.bz2"
DATESTRINGIMAGE="_database_snapshot.${DOCKERREPOSITORY}-${DATE}.image.tar.bz2"
DATESTRINGTAR="_database_snapshot.${DOCKERREPOSITORY}-${DATE}.image.tar"
### Change only above this line ####

MAINDIR=${DUMPSDIR}/${DOCKERREPOSITORY}
cd ${MAINDIR}

echo $(pwd)

echo "  ** START: $(date) **"
for DB in $(ls *${CURRENTSTRINGSQL} | grep -Ev ${IGNORE}); do
  DBNAME=$(echo ${DB} | awk -F'_' '{print $1}')

  echo "Building: ${DBNAME}";
  echo "  *** START: $(date) ***"

  echo "  Drop linux caches"
  echo 3 > /proc/sys/vm/drop_caches

  echo "  Starting new Mariadb container"
  CONTAINERID=$(docker run --memory=8g -e MYSQL_ROOT_PASSWORD=${DBPASS} -d ${IMAGE}:${TAG} ${MYSQLCONF})
  echo "Container ID: ${CONTAINERID}"
  #### Get container IP
  IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "${CONTAINERID}")
  echo "  Container IP: ${IP}"

  echo "  Letting MYSQL spin up"
  echo "  Sleeping for ${SLEEPTIME}" && sleep ${SLEEPTIME}
  nc -z ${IP} ${MYSQLPORT} || echo "  Sleeping for ${SLEEPTIME}" && sleep ${SLEEPTIME}
  nc -z ${IP} ${MYSQLPORT} || echo "  Sleeping for ${SLEEPTIME}" && sleep ${SLEEPTIME}

  echo "  Creating DB: ${DBNAME}"
  mysql -u ${DBUSER} -p${DBPASS} -h ${IP} -P ${MYSQLPORT} -e "CREATE DATABASE ${DBNAME}"

  echo "  Import data into database: ${DBNAME}"
  pbunzip2 < ${DBNAME}${CURRENTSTRINGSQL} | mysql -u ${DBUSER} -p${DBPASS} -h ${IP} -P ${MYSQLPORT} ${DBNAME}

  echo "  Stoping container with ID: ${CONTAINERID}"
  docker stop ${CONTAINERID}
  IMAGEID=$(docker commit ${CONTAINERID} ${DOCKERREPOSITORY}/${DBNAME}:${DATE})

  echo "  Removing container"
  docker rm ${CONTAINERID}

  echo "  Saving container"
  docker save ${IMAGEID} > ${DUMPSDIR}/tmp/${DBNAME}${DATESTRINGTAR}
  pbzip2 -fc < ${DUMPSDIR}/tmp/${DBNAME}${DATESTRINGTAR} > ${DBNAME}${DATESTRINGIMAGE}

  [ ! -z $(readlink ${DBNAME}${CURRENTSTRINGIMAGE}) ] && [ -f $(readlink ${DBNAME}${CURRENTSTRINGIMAGE}) ] && OLDIMAGE=$(readlink ${DBNAME}${CURRENTSTRINGIMAGE})
  ln -sf ${DBNAME}${DATESTRINGIMAGE} ${DBNAME}${CURRENTSTRINGIMAGE}

  echo "  Delete remmenents"
  [ -z ${OLDIMAGE} ] && rm -f ${OLDIMAGE}
  rm -f ${DUMPSDIR}/tmp/${DBNAME}${DATESTRINGTAR}
  docker rmi ${IMAGEID}
  echo "  Drop linux caches"
  echo 3 > /proc/sys/vm/drop_caches

  echo "  *** END: $(date) ***"
  echo "  ================================================================"
  echo "  ----------  Compressed IMAGE ${DBNAME}${DATESTRINGIMAGE} created"
  echo "  ================================================================"
done

cd ${MAINDIR}
echo "** END: $(date) **"
