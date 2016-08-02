#!/bin/bash

source snapshot/common.sh

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Generate a list of all databases to be sanitized
for db in $(sudo mysql -N -B -e 'SHOW DATABASES' | grep -v -e 'jira_assoc' -e 'information_schema' -e 'performance_schema' -e 'mysql' -e 'percona' -e 'temp' -e 'drupal_export'); do 
  echo "### Sanitizing ${db} ###"
  # If the sanitization is not set, use the DB name.
  [ "${sanitization-}" ] || sanitization=${db}

  tmp_db=${db}
  tmp_args="${tmp_db}"

  if [ ${db} == 'association_civicrm' ]; then
    skip_common=1
  else
    skip_common=0
  fi

  # Truncate all tables with cache in the name.
  echo "SHOW TABLES LIKE '%cache%';" | sudo mysql -o ${tmp_args} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | sudo mysql -o ${tmp_args}
  echo "SHOW TABLES LIKE 'civicrm_export_temp%';" | sudo mysql -o ${tmp_args} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | sudo mysql -o ${tmp_args}
  echo "SHOW TABLES LIKE 'civicrm_import_job%';" | sudo mysql -o ${tmp_args} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | sudo mysql -o ${tmp_args}

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

# Snapshot the staging level databases
suffix=.staging
snapshot
