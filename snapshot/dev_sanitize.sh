#!/bin/bash

source snapshot/common.sh

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

dblist="drupal_api drupal_association drupal_groups drupal_localize events"

# Generate a list of all databases and tables (except 'pift_ci_job_result'
# which is already compressed), and alter them to the compressed row_format.
for db in ${dblist}; do 
  echo "### Sanitizing ${db} ###"
  # Sanitize using the DB name.
  sanitization=${db}

  # Snapshot in stages.
  # A snapshot suitable for dev. We remove all private information.
  suffix=.dev
  sanitize

  echo "### Completed sanitizing ${db} ###"
done

# Snapshot the dev stage databases
suffix=.dev
snapshot
sudo find "/var/sanitize/drupal_export/${subdir}/" -mindepth 1 -maxdepth 1 -exec rm -rfv {} \+
