#!/bin/bash

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Generate a list of all databases and tables, and alter them to the compressed
# row_format.
for db in $(sudo mysql -N -B -e 'SHOW DATABASES' | grep -v -e 'jira_assoc' -e 'information_schema' -e 'performance_schema' -e 'mysql' -e 'percona' -e 'temp' -e 'drupal_export'); do 
  echo "### Compressing ${db} ###"
  for table in $(sudo mysql -N -B -e 'show tables' ${db}); do
    echo ${db}.${table};
    sudo mysql -e "ALTER TABLE ${table} ROW_FORMAT=compressed" ${db}
  done;
  echo "### Completed compressing ${db} ###"
done
