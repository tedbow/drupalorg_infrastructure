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
  fi

  # Truncate all tables with cache in the name.
  echo "SHOW TABLES LIKE '%cache%';" | sudo mysql -o ${db} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | sudo mysql -o ${db}
  echo "SHOW TABLES LIKE 'civicrm_export_temp%';" | sudo mysql -o ${db} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | sudo mysql -o ${db}
  echo "SHOW TABLES LIKE 'civicrm_import_job%';" | sudo mysql -o ${db} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | sudo mysql -o ${db}

  # Snapshot in stages.
  # Raw is nearly unsanitized, excpet for some keys. Git-dev uses this for emails.
  suffix=.raw
  sanitize

  # A snapshot suitable for staging. We remove emails to avoid emailing people.
  suffix=.staging
  sanitize
  echo "### Completed sanitizing ${db} ###"

  # Generate a list of all tables (except 'pift_ci_job_result' which is already
  # compressed), and alter them to the compressed row_format.
  echo "### Compressing ${db} ###"
  ( sudo mysql "$db" -e "SHOW TABLES" --batch --skip-column-names | grep -v 'pift_ci_job_result' | xargs -n 1 -P 6 -I{} sudo mysql -e 'ALTER TABLE `'{}'` ROW_FORMAT=COMPRESSED;' "$db")
  echo "### Completed compressing ${db} ###"
done

# Snapshot the staging stage databases
suffix=.staging
snapshot
sudo rm -rf /var/sanitize/drupal_export/${subdir}
