#!/bin/bash -e
############################################
# Use this script to recreate all containers
############################################
## Conf
BASEDIR=$HOME
DUMPSDIR="/var/dumps"
SLEEPTIME="30"
DATE=$(date +'%Y%m%d%H%M')
PBZCONCURRENCY="12"

## Docker conf
IMAGE=mariadb
TAG=10.0
DBUSER=root
DBPASS=drupal
DOCKERCONF="--memory=4g -e MYSQL_ROOT_PASSWORD=${DBPASS} -d ${IMAGE}:${TAG}"

## MariaDB conf
MYSQLCONF="--datadir=/mnt --max-allowed-packet=256M --innodb-log-file-size=1G --innodb-file-per-table=1 --innodb-file-format=barracuda"
MYSQLPORT="3306"

## Variables
DATE="${1}"
DOCKERREPOSITORY="${2}"
FILENAME="${3}"

## Script conf
CURRENTSTRINGSQL="_database_snapshot.${DOCKERREPOSITORY}-current.sql.bz2"
CURRENTSTRINGIMAGE="_database_snapshot.${DOCKERREPOSITORY}-current.image.tar.bz2"
DATESTRINGIMAGE="_database_snapshot.${DOCKERREPOSITORY}-${DATE}.image.tar.bz2"
DATESTRINGTAR="_database_snapshot.${DOCKERREPOSITORY}-${DATE}.image.tar"

### Change only above this line ####

MAINDIR=${DUMPSDIR}/${DOCKERREPOSITORY}

### Parse DBNAME, DOCKERREPOSITORY and DBNAME short name
DBNAME=$(echo ${FILENAME} | awk -F'_' '{print $1}')
DR=$(echo ${DOCKERREPOSITORY} | cut -c1 )
DN=$(echo ${DBNAME} | cut -c1-2 )

echo "${DR}/${DN} | Building: ${DBNAME} at $(date)";

echo "${DR}/${DN} | Starting new Mariadb container"
CONTAINERID=$(docker run ${DOCKERCONF} ${MYSQLCONF})
echo "${DR}/${DN} | Container ID: ${CONTAINERID}"

#### Get container IP
IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "${CONTAINERID}")
echo "${DR}/${DN} | Container IP: ${IP}"

### Letting MariaDB spin up
echo "${DR}/${DN} | Sleeping for ${SLEEPTIME}" && sleep ${SLEEPTIME}
nc -z ${IP} ${MYSQLPORT} || ( echo "${DR}/${DN} | Sleeping for ${SLEEPTIME}" && sleep ${SLEEPTIME} )
nc -z ${IP} ${MYSQLPORT} || ( echo "${DR}/${DN} | Sleeping for ${SLEEPTIME}" && sleep ${SLEEPTIME} )

echo "${DR}/${DN} | Creating DB: ${DBNAME}"
mysql -u ${DBUSER} -p${DBPASS} -h ${IP} -P ${MYSQLPORT} -e "CREATE DATABASE ${DBNAME}"

echo "${DR}/${DN} | Import data into database: ${DBNAME}"
pbunzip2 -dc -p${PBZCONCURRENCY} < ${MAINDIR}/${DBNAME}${CURRENTSTRINGSQL} | mysql -u ${DBUSER} -p${DBPASS} -h ${IP} -P ${MYSQLPORT} ${DBNAME}

echo "${DR}/${DN} | Stoping container with ID: ${CONTAINERID}"
docker stop ${CONTAINERID}
echo "${DR}/${DN} | Commiting container with ID: ${CONTAINERID}"
IMAGEID=$(docker commit --message="{DOCKERREPOSITORY}/${DBNAME}:${DATE}" ${CONTAINERID} ${DOCKERREPOSITORY}/${DBNAME}:${DATE})

echo "${DR}/${DN} | Saving container: ${IMAGEID}"
docker save ${DOCKERREPOSITORY}/${DBNAME}:${DATE} > ${DUMPSDIR}/tmp/${DBNAME}${DATESTRINGTAR}
echo "${DR}/${DN} | Compressing: ${DBNAME}${DATESTRINGTAR}"
pbzip2 -fc -p${PBZCONCURRENCY} < ${DUMPSDIR}/tmp/${DBNAME}${DATESTRINGTAR} > ${MAINDIR}/${DBNAME}${DATESTRINGIMAGE}

[ ! -z $(readlink ${MAINDIR}/${DBNAME}${CURRENTSTRINGIMAGE}) ] && [ -f $(readlink ${MAINDIR}/${DBNAME}${CURRENTSTRINGIMAGE}) ] && OLDIMAGE=$(readlink ${MAINDIR}/${DBNAME}${CURRENTSTRINGIMAGE})
ln -sf ${MAINDIR}/${DBNAME}${DATESTRINGIMAGE} ${MAINDIR}/${DBNAME}${CURRENTSTRINGIMAGE}

echo "${DR}/${DN} | Delete remmenents"
[ ! -z ${OLDIMAGE} ] && echo "${DR}/${DN} || Deleting old image: ${OLDIMAGE}" && rm -f ${OLDIMAGE}
echo "${DR}/${DN} || Deleting: ${DUMPSDIR}/tmp/${DBNAME}${DATESTRINGTAR}"
rm -f ${DUMPSDIR}/tmp/${DBNAME}${DATESTRINGTAR}
echo "${DR}/${DN} || Removing container: ${CONTAINERID}"
docker rm ${CONTAINERID}
echo "${DR}/${DN} || Deleting Image: ${IMAGEID}"
docker rmi ${IMAGEID}

echo "${DR}/${DN} | End: Compressed IMAGE ${DBNAME}${DATESTRINGIMAGE} created at $(date)"
