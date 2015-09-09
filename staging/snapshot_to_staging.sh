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
rsync -v --copy-links --password-file ~/util.rsync.pass "rsync://stagingmysql@dbutil.drupal.org/mysql-${snaptype}/${snapshot}_database_snapshot.${snaptype}-current.sql.bz2" "${WORKSPACE}"

# Clear out the DB and import a snapshot.
(
  echo "DROP DATABASE ${db};"
  echo "CREATE DATABASE ${db};"
  echo "USE ${db};"
  bunzip2 < "${WORKSPACE}/${snapshot}_database_snapshot.${snaptype}-current.sql.bz2"
) | ${drush} ${sqlcli}

if [ "${suffix-}" != "civicrm" ]; then
  # Promote the inactive database to active
  swap_db
fi

# Clear caches, try updatedb.
${drush} cc all
${drush} -v updatedb --interactive

if [ "${uri}" = "groups-7.staging.devdrupal.org" ]; then
  # todo remove when the existing front page, "frontpage", does not 404.
  ${drush} variable-set site_frontpage "node"

elif echo "${uri}" | grep -qE "civicrm.staging.devdrupal.org$|^jobs.devdrupal.org$|^jobs-tiger.devdrupal.org$"; then
  # CiviCRM and Jobs dev sites do not have bakery set up.
  ${drush} pm-disable bakery
fi

# Prime caches for home page and make sure site is basically working.
test_site
