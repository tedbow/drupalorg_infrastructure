# Include common staging script.
. staging/common.sh 'snapshot_to'

# Get the DB name from drush
db=$(${drush} ${sqlconf} | sed -ne 's/^\s*\[database\] => //p')
if [ "${suffix-}" != "civicrm" ]; then
  # Use the inactive db for import
  db=$([[ "${db}" == *1 ]] && echo "${db%?}" || echo "${db}1")
fi

# If a snapshot has not been already set in $snapshot, get it from $uri,
# everything before the first '.' or '-'.
[ "${snapshot-}" ] || snapshot=$(echo ${uri} | sed -e 's/[.-].*$//')

# If a snapshot type has been designated, use that. Otherwise, default to
# the 'staging' snapshot.
[ "${snaptype-}" ] || snaptype=staging

# Copy snapshot.
rsync -v --copy-links --password-file ~/util.rsync.pass "rsync://stagingmysql@dbutil.drupalsystems.org/mysql-${snaptype}/${snapshot}_database_snapshot.${snaptype}-current.sql.bz2" "${WORKSPACE}"

# Clear out the DB and import a snapshot.
(
  echo "DROP DATABASE ${db};"
  echo "CREATE DATABASE ${db};"
  echo "USE ${db};"
  pbzip2 -d < "${WORKSPACE}/${snapshot}_database_snapshot.${snaptype}-current.sql.bz2"
) | ${drush} ${sqlcli}

if [ "${suffix-}" != "civicrm" ]; then
  # Promote the inactive database to active
  swap_db
fi

# run updb, this clears the caches after whether updates exist or not.
${drush} -v updb --interactive

if [ "${uri}" = "groups-7.staging.devdrupal.org" ]; then
  # todo remove when the existing front page, "frontpage", does not 404.
  ${drush} variable-set site_frontpage "node"

elif echo "${uri}" | grep -qE "civicrm.staging.devdrupal.org$|^jobs.dev.devdrupal.org$|^jobs-tiger.dev.devdrupal.org$"; then
  # CiviCRM and Jobs dev sites do not have bakery set up.
  ${drush} pm-disable bakery
fi

# Clean up solr
${drush} vset apachesolr_default_environment solr_0
${drush} solr-set-env-url --id="solr_0" http://stagingsolr1.drupal.aws:8080/solr/do-core1
${drush} ev "apachesolr_environment_delete(solr_0_0)"

# Prime caches for home page and make sure site is basically working.
test_site
