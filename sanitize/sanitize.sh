#!/bin/bash

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
dbopt="--single-transaction --quick"
stage="dev"
filetype="sql"
compression="bz2"
dumppath="/var/dumps/${stage}"

# Variables exported by Jenkins
JOB_NAME=${JOB_NAME:=db_backup}
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

# Copy the raw database to the sanitization host (i.e. dbutil)
# Set tmp_args2 of the database being transferred to the sanitization host
# @TODO: db6-reader-vip should be a variable
tmp_args2="-hdb6-reader-vip.drupal.org ${dbuser:= } ${dbpassword:= }"
time mysqldump ${dbopt} ${tmp_args2} ${database} | mysql ${tmp_args} ${database}_sanitize

# Sanitize into the export database.
python2.6 $cwd/sanitize_db.py -s ${database}_sanitize -d ${export_db} -p ${profile}
if [ $? -ne 0 ]; then
  exit $?
fi

### Dump the sanitized data
fvar1="${JOB_NAME}.${stage}"
suffix="${filetype}.${compression}"
dumpinprogress="${fvar1}-${BUILD_NUMBER}-in-progress"
dumpfile="${fvar1}-${BUILD_NUMBER}.${suffix}"
dumpcur="${dumppath}/${fvar1}-current.${suffix}"

# Save the DB dump, strip ENGINE type from the output
echo "start the dump"
mysqldump ${dbopt} ${tmp_args} ${export_db} | sed -e 's/^) ENGINE=[^ ]*/)/' | pbzip2 -fc > ${dumppath}/${dumpinprogress}.${suffix}

# Move -in-progress to final location and symlink to current
mv -v ${dumppath}/${dumpinprogress}.${suffix} ${dumppath}/${dumpfile}
ln -sfv ${dumpfile} ${dumpcur}

# Remove old snapshots.
old_snapshots=$(ls -t ${dumppath}/${fvar1}-[0-9]*.${filetype}.{bz2,gz} | tail -n +2)
if [ ! -z "${old_snapshots}" ]; then
  rm -v ${old_snapshots}
fi

