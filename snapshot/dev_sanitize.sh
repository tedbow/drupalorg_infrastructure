#!/bin/bash

source snapshot/common.sh

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Generate a list of all databases and tables (except 'pift_ci_job_result'
# which is already compressed), and alter them to the compressed row_format.
for db in $(sudo mysql -N -B -e 'SHOW DATABASES' | grep -v -e 'jira_assoc' -e 'information_schema' -e 'performance_schema' -e 'mysql' -e 'percona' -e 'temp' -e 'drupal_export'); do 
  echo "### Sanitizing ${db} ###"
  # Sanitize using the DB name.
  sanitization=${db}

  tmp_db=${db}
  tmp_args="${tmp_db}"

  if [ ${db} == 'association_civicrm' ]; then
    skip_common=1
  else
    skip_common=0
  fi

  # Snapshot in stages.
  # A snapshot suitable for dev. We remove all private information.
  suffix=.dev
  sanitize

  echo "### Completed sanitizing ${db} ###"
done

# Snapshot the dev stage databases
suffix=.dev
snapshot
