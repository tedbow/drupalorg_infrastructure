#!/bin/bash

# Run a snapshot phase. See below for how it is called. ${suffix} is the phase
# and used in filenames.
function sanitize {
  # Allow skipping common sanitization. For CiviCRM and anything else
  # non-Drupal.
  if [ ! "${skip_common-}" ]; then
    # Execute common SQL commands.
    [ -f "snapshot/common${suffix}.sql" ] && sudo mysql -o ${tmp_args} < "snapshot/common${suffix}.sql"
    # Execute common SQL commands, but don't exit if they fail.
    [ -f "snapshot/common-force${suffix}.sql" ] && sudo mysql -f -o ${tmp_args} < "snapshot/common-force${suffix}.sql"
  fi

  # Skip if this sanitization and phase does not exit.
  [ ! -f "snapshot/${sanitization}${suffix}.sql" ] && return
  # Execute SQL for this sanitization and phase.
  sudo mysql -o ${tmp_args} < "snapshot/${sanitization}${suffix}.sql"
  # Save a copy of the schema.
  sudo mysqldump --no-data --single-transaction --quick --max-allowed-packet=256M ${tmp_args} > "/var/sanitize/drupal_export/${db}${suffix}-schema.sql"

}

function snapshot {
  # Remove initial '.'
  subdir=$(echo "${suffix}" | sed -e 's/^\.//')
  # Store reduce with dev, they are the same level of sanitization.
  if [ "${subdir}" = 'reduce' ]; then
    subdir='dev'
  fi
  # Create and save a binary snapshot.
  sudo rm -rf /var/sanitize/drupal_export/${subdir}
  sudo innobackupex --no-timestamp /var/sanitize/drupal_export/${subdir}
  sudo innobackupex --apply-log --export "/var/sanitize/drupal_export/${subdir}"
  sudo chown -R bender:bender "/var/sanitize/drupal_export/${subdir}"
  # Create a tarball for each database
  for db in ${dblist}; do
    mv "/var/sanitize/drupal_export/${db}${suffix}-schema.sql" "/var/sanitize/drupal_export/${subdir}/${db}"
    cd "/var/sanitize/drupal_export/${subdir}/${db}"
    tar -czvf "/var/dumps/${subdir}/${db}${suffix}-${BUILD_NUMBER}-binary.tar.gz" "./"
    sudo chown -R bender:bender "/var/dumps/${subdir}/${db}${suffix}-${BUILD_NUMBER}-binary.tar.gz"
    ln -sfv "${db}${suffix}-${BUILD_NUMBER}-binary.tar.gz" "/var/dumps/${subdir}/${db}${suffix}-binary-current.tar.gz"
    # Remove old binary snapshots
    old_snapshots=$(ls -t /var/dumps/${subdir}/${db}${suffix}-[0-9]*-binary.tar.gz | tail -n +2)
    if [ -n "${old_snapshots}" ]; then
      rm -v ${old_snapshots}
    fi
    # Also create old mysqldump snapshots for dev databases that aren't using
    # the whitelist.
    if [ "${subdir}" == 'dev' && "${db}" != 'drupal' ]; then
      sudo mysqldump --single-transaction --quick --max-allowed-packet=256M ${db} | pbzip2 -p6 > "/var/dumps/${subdir}/${db}${suffix}-${BUILD_NUMBER}-in-progress.sql.bz2"
      sudo chown -R bender:bender "/var/dumps/${subdir}/${db}${suffix}-${BUILD_NUMBER}-in-progress.sql.bz2"
      mv -v "/var/dumps/${subdir}/${db}${suffix}-${BUILD_NUMBER}-in-progress.sql.bz2" "/var/dumps/${subdir}/${db}${suffix}-${BUILD_NUMBER}.sql.bz2"
      ln -sfv "${db}${suffix}-${BUILD_NUMBER}.sql.bz2" "/var/dumps/${subdir}/${db}${suffix}-current.sql.bz2"
      # Remove old snapshots.
      old_snapshots=$(ls -t /var/dumps/${subdir}/${db}${suffix}-[0-9]*.sql.{bz2,gz} | tail -n +2)
      if [ -n "${old_snapshots}" ]; then
        rm -v ${old_snapshots}
      fi
    fi
    cd "/usr/local/drupal-infrastructure"
  done
}

function clear_tmp {
  echo "DROP DATABASE IF EXISTS ${tmp_db}; CREATE DATABASE ${tmp_db};" | sudo mysql ${tmp_args}
}
