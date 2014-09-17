#!/bin/bash

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

## Get scripts current working directory
CWD=$( dirname "${BASH_SOURCE[0]}" )

# Check if variables have been entered
function help {
  echo "sanitize.sh <database> <boss|infra|redated|skeleton>"
  exit 1
}

### Variables ###
DATABASE=${1:=-h}
PROFILE=${2:=empty}
NODUMP=${3:-dump}

EXPORT_DB="drupal_export"

DBOPT="--single-transaction --quick"

DIR=$PROFILE
STAGE="$DIR"
FILETYPE="sql"
COMPRESSION="bz2"
JOB_NAME=${JOB_NAME:=db_backup}
BUILD_NUMBER=${BUILD_NUMBER:=0}


DUMPPATH="/var/dumps/${DIR}"


### Variables ###

if [[ -z "${DATABASE}" ]] || [[ -z "${PROFILE}" ]]
  then
  help
fi

case ${DATABASE} in
  "-h"|"--help"|"")
    help
    ;;
esac

case ${PROFILE} in
  "boss"|"infra"|"redacted"|"skeleton")
    ;;
  *)
    help
    ;;
esac
# Grab the profile argument:
#
# Infra - infrastructure dev
# Boss - for drupal.org
# Skeleton - for drupal.org dev

# We are only creating dev snapshots right now.

# Stop script if dump dir doesn't exist and can't be made by this user
[ ! -d ${DUMPPATH} ] && mkdir -p ${DUMPPATH}
[ ! -d ${DUMPPATH} ] && exit 1

# Make sure that the directory is writeable
touch ${DUMPPATH}/.test-write || exit 1
rm ${DUMPPATH}/.test-write || exit 1

# Grab the host, user and password from password.py
[ ! -f $CWD/password.py ] && echo "Missing password.py file" && exit 1
source $CWD/password.py

[ -z "${host}" ] &&  echo "Missing host in password.py file." && exit 1
[ ! -z "${host}" ] && DBHOST="-h${host}"
[ ! -z "${user}" ] && DBUSER="-u${user}"
[ ! -z "${password}" ] && DBPASSWORD="-p${password}"

TMP_ARGS="${DBHOST} ${DBUSER:= } ${DBPASSWORD:= } ${EXPORT_DB}"

##if [ ${DATABASE} == "drupal" ]; then
##  DATABASE="drupal_sanitize"
##  STAGE="whitelist"
##  TMP_ARGS2="-hdb2-main-vip.drupal.org ${DBUSER:= } ${DBPASSWORD:= } ${EXPORT_DB}"
##  time mysqldump ${DBOPT} ${TMP_ARGS2} drupal | mysql ${TMP_ARGS} ${DATABASE}
##fi

# Sanitize into the export database.
python2.6 $CWD/sanitize_db.py -s ${DATABASE} -d ${EXPORT_DB} -p ${PROFILE}
if [ $? -ne 0 ]; then
  exit $?
fi


if [ ${NODUMP} == "dump" ]; then
  FVAR1="${JOB_NAME}.${STAGE}"
  SUFFIX="${FILETYPE}.${COMPRESSION}"
  DUMPPROG="${FVAR1}-${BUILD_NUMBER}-in-progress"
  DUMPFILE="${FVAR1}-${BUILD_NUMBER}.${SUFFIX}"
  DUMPCUR="${DUMPPATH}/${FVAR1}-current.${SUFFIX}"

  # Save the DB dump.
  echo "start the dump"
  mysqldump ${DBOPT} ${TMP_ARGS} > ${DUMPPATH}/${DUMPPROG}.${FILETYPE}
  cat ${DUMPPATH}/${DUMPPROG}.${FILETYPE} | sed -e 's/^) ENGINE=[^ ]*/)/' > ${DUMPPATH}/sed-${DUMPPROG}.${FILETYPE} && rm ${DUMPPATH}/${DUMPPROG}.${FILETYPE}
  echo "start the compression"
  pbzip2 -fc ${DUMPPATH}/sed-${DUMPPROG}.${FILETYPE} > ${DUMPPATH}/${DUMPPROG}.${SUFFIX} && rm ${DUMPPATH}/sed-${DUMPPROG}.${FILETYPE}
  mv -v ${DUMPPATH}/${DUMPPROG}.${SUFFIX} ${DUMPPATH}/${DUMPFILE}
  ln -sfv ${DUMPFILE} ${DUMPCUR}

  # Remove old snapshots.
  OLD_SNAPSHOTS=$(ls -t ${DUMPPATH}/${FVAR1}-[0-9]*.${FILETYPE}.{bz2,gz} | tail -n +2)
  if [ -z "${OLD_SNAPSHOTS}" ]; then
    rm -v ${OLD_SNAPSHOTS}
  fi
fi

