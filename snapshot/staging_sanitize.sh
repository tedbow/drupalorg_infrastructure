#!/bin/bash

source snapshot/common.sh

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

dblist="association_civicrm drupal drupal_api drupal_association drupal_groups drupal_jobs drupal_localize drupal_security events"

# Generate a list of all databases to be sanitized
for db in ${dblist}; do 
  echo "### Sanitizing ${db} ###"
  # Sanitize using the DB name.
  sanitization=${db}

  if [ ${db} == 'association_civicrm' ]; then
    skip_common=1
  else
    skip_common=0
  fi

  # Truncate all tables with cache in the name.
  echo "SHOW TABLES LIKE '%cache%';" | sudo mysql -o ${db} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | sudo mysql -o ${db}
  echo "SHOW TABLES LIKE 'civicrm_export_temp%';" | sudo mysql -o ${db} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | sudo mysql -o ${db}
  echo "SHOW TABLES LIKE 'civicrm_import_job%';" | sudo mysql -o ${db} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | sudo mysql -o ${db}

  # Ensure all tables are InnoDB
  for tbl in $(sudo mysql ${db} -B -N -e "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = \"${db}\" AND engine = 'MyISAM';"); do
    sudo mysql -o ${db} -e "ALTER TABLE ${tbl} ENGINE=InnoDB;"
  done

  # Snapshot in stages.
  # Raw is nearly unsanitized, excpet for some keys. Git-dev uses this for emails.
  suffix=.raw
  sanitize

  # A snapshot suitable for staging. We remove emails to avoid emailing people.
  suffix=.staging
  sanitize
  echo "### Completed sanitizing ${db} ###"

  # Generate a list of all tables (except 'pift_ci_job_result' which is already
  # compressed, and civicrm_domain_view which is a view), and alter them to the
  # compressed row_format.
  echo "### Compressing ${db} ###"
  ( sudo mysql "$db" -e "SHOW TABLES" --batch --skip-column-names | grep -v --line-regexp 'pift_ci_job_result\|civicrm_domain_view' | xargs -n 1 -I{} sudo mysql -e 'ALTER TABLE `'{}'` ROW_FORMAT=COMPRESSED;' "$db")
  echo "### Completed compressing ${db} ###"
done

# Snapshot the staging stage databases
suffix=.staging
snapshot
sudo find "/var/sanitize/drupal_export/${subdir}/" -mindepth 1 -maxdepth 1 -exec rm -rfv {} \+
