#!/bin/bash

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Generate a list of all databases and tables (except 'pift_ci_job_result'
# which is already compressed), and alter them to the compressed row_format.
for db in $(sudo mysql -N -B -e 'SHOW DATABASES' | grep -v -e 'jira_assoc' -e 'information_schema' -e 'performance_schema' -e 'mysql' -e 'percona' -e 'temp' -e 'drupal_export'); do 
  echo "### Compressing ${db} ###"
  ( sudo mysql "$db" -e "SHOW TABLES" --batch --skip-column-names | grep -v 'pift_ci_job_result' | xargs -n 1 -P 6 -I{} sudo mysql -e 'ALTER TABLE `'{}'` ROW_FORMAT=COMPRESSED;' "$db")
  echo "### Completed compressing ${db} ###"
done
