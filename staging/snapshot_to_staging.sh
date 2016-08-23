#!/bin/bash

# Include common staging script.
. staging/common.sh 'snapshot_to'

# Get the DB name from drush
db=$(${drush} ${sqlconf} | sed -ne 's/^\s*\[database\] => //p')
if [ "${suffix-}" != "civicrm" ]; then
  # Use the inactive db for import
  target_db=$([[ "${db}" == *1 ]] && echo "${db%?}" || echo "${db}1")
else
  target_db=${db}
fi

# Set DB to the original DB name for snapshot imports
db=$(echo ${db} | sed -e 's/1$//')

# Clear out the DB and import a snapshot.
(
  echo "DROP DATABASE ${target_db};"
  echo "CREATE DATABASE ${target_db};"
) | ${drush} ${sqlcli}

ssh dbstg1.drupal.bak sudo /usr/local/drupal-infrastructure/staging/snapshot_to_dbstg.sh ${db} ${target_db}

if [ "${suffix-}" != "civicrm" ]; then
  # Promote the inactive database to active
  swap_db
fi

# run updb, this clears the caches after whether updates exist or not.
${drush} -v updb --interactive

if [ "${uri}" = "groups-7.staging.devdrupal.org" ]; then
  # todo remove when the existing front page, "frontpage", does not 404.
  ${drush} variable-set site_frontpage "node"
fi

# Clean up solr (if enabled)
if ${drush} pm-list --status=enabled | grep -q apachesolr; then
  ${drush} vset apachesolr_default_environment solr_0
  ${drush} solr-set-env-url --id="solr_0" http://solrstg-vip.drupal.bak:8983/solr/do-core1
  ${drush} ev "apachesolr_environment_delete(solr_0_0)"
fi

# Prime caches for home page and make sure site is basically working.
test_site
