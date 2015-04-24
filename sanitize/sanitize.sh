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
export_db="drupal_export"
dbopt="--single-transaction --quick"
dir=$profile
stage="$dir"
filetype="sql"
compression="bz2"
dumppath="/var/dumps/${dir}"

# Variables exported by Jenkins
JOB_NAME=${JOB_NAME:=db_backup}
BUILD_NUMBER=${BUILD_NUMBER:=0}
### Variables ###

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

tmp_args="${dbhost} ${dbuser:= } ${dbpassword:= } ${export_db}"

if [ ${database} == "drupal" ]; then
  database="drupal_sanitize"
  stage="whitelist"
  tmp_args2="-hdb6-reader-vip.drupal.org ${dbuser:= } ${dbpassword:= } ${export_db}"
  time mysqldump ${dbopt} ${tmp_args2} drupal | mysql ${tmp_args} ${database}
fi

# Sanitize into the export database.
python2.6 $cwd/sanitize_db.py -s ${database} -d ${export_db} -p ${profile}
if [ $? -ne 0 ]; then
  exit $?
fi

### Dump the sanitized data
fvar1="${JOB_NAME}.${stage}"
suffix="${filetype}.${compression}"
dumpprog="${fvar1}-${BUILD_NUMBER}-in-progress"
dumpfile="${fvar1}-${BUILD_NUMBER}.${suffix}"
dumpcur="${dumppath}/${fvar1}-current.${suffix}"

# Save the DB dump.
echo "start the dump"
mysqldump ${dbopt} ${tmp_args} > ${dumppath}/${dumpprog}.${filetype}

# Strip any ENGINE data from the dump, store in temporary sed file
cat ${dumppath}/${dumpprog}.${filetype} | sed -e 's/^) ENGINE=[^ ]*/)/' > ${dumppath}/sed-${dumpprog}.${filetype} && rm ${dumppath}/${dumpprog}.${filetype}
echo "start the compression"

# Compress into original in-progress file and remove temporary sed file
pbzip2 -fc ${dumppath}/sed-${dumpprog}.${filetype} > ${dumppath}/${dumpprog}.${suffix} && rm ${dumppath}/sed-${dumpprog}.${filetype}

# Move -in-progress to final location and symlink to current
mv -v ${dumppath}/${dumpprog}.${suffix} ${dumppath}/${dumpfile}
ln -sfv ${dumpfile} ${dumpcur}

# Remove old snapshots.
old_snapshots=$(ls -t ${dumppath}/${fvar1}-[0-9]*.${filetype}.{bz2,gz} | tail -n +2)
if [ ! -z "${old_snapshots}" ]; then
  rm -v ${old_snapshots}
fi

