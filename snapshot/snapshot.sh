#!/bin/bash

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Run a snapshot phase. See below for how it is called. ${suffix} is the phase
# and used in filenames.
function snapshot {
  # Allow skipping common sanitization. For CiviCRM and anything else
  # non-Drupal.
  if [ ! "${skip_common-}" ]; then
    # Execute common SQL commands.
    [ -f "snapshot/common${suffix}.sql" ] && mysql -o ${tmp_args} < "snapshot/common${suffix}.sql"
    # Execute common SQL commands, but don't exit if they fail.
    [ -f "snapshot/common-force${suffix}.sql" ] && mysql -f -o ${tmp_args} < "snapshot/common-force${suffix}.sql"
  fi

  # Skip if this sanitization and phase does not exit.
  [ ! -f "snapshot/${sanitization}${suffix}.sql" ] && return
  # Execute SQL for this sanitization and phase.
  #mysql -o ${tmp_args} < "snapshot/${sanitization}${suffix}.sql"
  cat "snapshot/${sanitization}${suffix}.sql" | sed -e 's/^) ENGINE=[^ ]*/) ENGINE=aria/' | mysql -o ${tmp_args}

  # Remove initial '.'
  subdir=$(echo "${suffix}" | sed -e 's/^\.//')
  # Store reduce with dev, they are the same level of sanitization.
  if [ "${subdir}" = 'reduce' ]; then
    subdir='dev'
  fi
  # Save the DB dump.
  mysqldump --single-transaction --quick ${tmp_args} | sed -e 's/^) ENGINE=[^ ]*/)/' | bzip2 > "/var/dumps/${subdir}/${JOB_NAME}${suffix}-${BUILD_NUMBER}-in-progress.sql.bz2"
  mv -v "/var/dumps/${subdir}/${JOB_NAME}${suffix}-${BUILD_NUMBER}-in-progress.sql.bz2" "/var/dumps/${subdir}/${JOB_NAME}${suffix}-${BUILD_NUMBER}.sql.bz2"
  ln -sfv "${JOB_NAME}${suffix}-${BUILD_NUMBER}.sql.bz2" "/var/dumps/${subdir}/${JOB_NAME}${suffix}-current.sql.bz2"

  # Remove old snapshots.
  old_snapshots=$(ls -t /var/dumps/${subdir}/${JOB_NAME}${suffix}-[0-9]*.sql.{bz2,gz} | tail -n +2)
  if [ -n "${old_snapshots}" ]; then
    rm -v ${old_snapshots}
  fi
}

function clear_tmp {
  echo "DROP DATABASE ${tmp_db}; CREATE DATABASE ${tmp_db};" | mysql ${tmp_args}
}

# Configure credentials
db_name=$1
db_user=$2
db_pass=$3

# If the sanitization is not set, use the DB name.
[ "${sanitization-}" ] || sanitization=${db_name}
# If the DB host is not set, use db4-static.
[ "${db_host-}" ] || db_host=db4-static.drupal.org

tmp_db=drupal_sanitize
tmp_user=sanitize_rw
tmp_pass=$4
tmp_host=db4-static.drupal.org
tmp_args="-h${tmp_host} -u${tmp_user} -p${tmp_pass} ${tmp_db}"

clear_tmp

# Make a copy of live.
mysqldump -h$db_host -u$db_user -p$db_pass --single-transaction --quick $db_name 2> "${WORKSPACE}/mysqldump-errors.txt" | gzip > "${WORKSPACE}/tmp.mysql.gz"
# Check for errors.
if [ -s "${WORKSPACE}/mysqldump-errors.txt" ]; then
  rm "${WORKSPACE}/tmp.mysql.gz"
  cat "${WORKSPACE}/mysqldump-errors.txt"
  exit 1
fi
# Copy live to tmp database.
gunzip < "${WORKSPACE}/tmp.mysql.gz" | mysql -o ${tmp_args}
rm "${WORKSPACE}/tmp.mysql.gz"

# Save a copy of the schema.
mysqldump --single-transaction --quick ${tmp_args} -d --compact --skip-opt > "${WORKSPACE}/schema.mysql"

# Truncate all tables with cache in the name.
echo "SHOW TABLES LIKE '%cache%';" | mysql -o ${tmp_args} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | mysql -o ${tmp_args}
echo "SHOW TABLES LIKE 'civicrm_export_temp%';" | mysql -o ${tmp_args} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | mysql -o ${tmp_args}
echo "SHOW TABLES LIKE 'civicrm_import_job%';" | mysql -o ${tmp_args} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | mysql -o ${tmp_args}

# Snapshot in stages.

# Raw is nearly unsanitized, excpet for some keys. Git-dev uses this for emails.
suffix=.raw
snapshot

# A snapshot suitable for staging. We remove emails to avoid emailing people.
suffix=.staging
snapshot

# A snapshot suitable for dev. We remove all private information.
suffix=.dev
snapshot

# A smaller snapshot for taking up less space on dev.
suffix=.reduce
snapshot

clear_tmp
