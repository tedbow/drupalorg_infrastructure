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
  mysql -o ${tmp_args} < "snapshot/${sanitization}${suffix}.sql"

  # Show tables for debugging.
  echo "SHOW TABLES;" | mysql -o ${tmp_args}

  # Save the DB dump.
  mysqldump --single-transaction ${tmp_args} | sed -e 's/^) ENGINE=[^ ]*/)/' | bzip2 > "/var/dumps/mysql/${JOB_NAME}${suffix}-${BUILD_NUMBER}-in-progress.sql.bz2"
  mv -v "/var/dumps/mysql/${JOB_NAME}${suffix}-${BUILD_NUMBER}-in-progress.sql.bz2" "/var/dumps/mysql/${JOB_NAME}${suffix}-${BUILD_NUMBER}.sql.bz2"
  ln -sfv "/var/dumps/mysql/${JOB_NAME}${suffix}-${BUILD_NUMBER}.sql.bz2" "/var/dumps/mysql/${JOB_NAME}${suffix}-current.sql.bz2"

  # Remove old snapshots.
  old_snapshots=$(ls -t /var/dumps/mysql/${JOB_NAME}${suffix}-[0-9]*.sql.{bz2,gz} | tail -n +2)
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
# If the DB host is not set, use db3-vip.
[ "${db_host-}" ] || db_host=db3-vip.drupal.org

tmp_db=drupal_sanitize
tmp_user=sanitize_rw
tmp_pass=$4
tmp_host=db3-vip.drupal.org
tmp_args="-h${tmp_host} -u${tmp_user} -p${tmp_pass} ${tmp_db}"

ln -sf /var/dumps $WORKSPACE/dumps

clear_tmp

# Copy live to tmp.
mysqldump -h$db_host -u$db_user -p$db_pass --single-transaction $db_name 2> mysqldump-errors.txt | mysql -o ${tmp_args}
[ -s mysqldump-errors.txt ] && cat mysql-errors.txt && exit 1

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
