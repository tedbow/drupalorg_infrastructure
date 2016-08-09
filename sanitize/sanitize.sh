#!/bin/bash

source snapshot/common.sh

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Get scripts current working directory
cwd=$( dirname "${BASH_SOURCE[0]}" )

# Help function
function help {
  echo "sanitize.sh <database> <boss|redacted|skeleton>"
  exit 1
}

### Variables ###
database=${1:=-h}
profile=${2:=empty}
export_db="${database}_export"

# Variables exported by Jenkins
JOB_NAME=${JOB_NAME:=db_backup}
JOB_NAME=$(echo $JOB_NAME | sed -e 's/_whitelist//')
BUILD_NUMBER=${BUILD_NUMBER:=0}
### End Variables ###

### Argument check ###
if [[ -z "${database}" ]] || [[ -z "${profile}" ]]
  then
  help
fi
case ${database} in
  "-h"|"--help"|"")
    help
    ;;
esac
case ${profile} in
  "boss"|"redacted"|"skeleton")
    ;;
  *)
    help
    ;;
esac
### End Argument check ###

# Grab the host, user and password from password.py
[ ! -f $cwd/password.py ] && echo "Missing password.py file" && exit 1
source $cwd/password.py
[ -z "${host}" ] &&  echo "Missing host in password.py file." && exit 1
[ ! -z "${host}" ] && dbhost="-h${host}"
[ ! -z "${user}" ] && dbuser="-u${user}"
[ ! -z "${password}" ] && dbpassword="-p${password}"

# Set the tmp_args for the database to be sanitized
tmp_args="${dbhost} ${dbuser:= } ${dbpassword:= }"

# Sanitize into the export database.
python $cwd/sanitize_db.py -s ${database} -d ${export_db} -p ${profile}
if [ $? -ne 0 ]; then
  exit $?
fi

# Snapshot the dev stage database
suffix=.dev
dblist="drupal_export"
whitelist=1
snapshot
sudo rm -rf /var/sanitize/drupal_export/${subdir}
