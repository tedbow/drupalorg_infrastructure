# Include common staging script.
. staging/common.sh 'snapshot_to'

# Get the DB name from drush
db=$(${drush} ${type}sql-conf | sed -ne 's/^\s*\[database\] => //p')

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
) | ${drush} ${type}sql-cli

if [ "${suffix-}" != "civicrm" ]; then
  # Promote the inactive database to active
  swap_db
fi

# Extra preparation for D7.
if [ "${uri}" = "localize-7.staging.devdrupal.org" ]; then
  (
    # OG needs new entity module.
    echo "UPDATE system SET status = 0 WHERE name IN ('og');"
  ) | ${drush} sql-cli
fi

# Clear caches, try updatedb.
if [ "${uri}" != "localize-7.staging.devdrupal.org" ]; then
  ${drush} cc all
fi
${drush} -v updatedb --interactive

if [ "${uri}" = "localize-7.staging.devdrupal.org" ]; then
  # Set the flag for OG to have global group roles
  ${drush} variable-set og_7000_access_field_default_value 0

  # Enable required modules.
  ${drush} en og_context og_ui migrate

  # Display a birdview of OG migration and migrate data.
  ${drush} ms
  ${drush} mi --all

  # Revert view og_members_ldo.
  ${drush} views-revert og_members_ldo

  # Disable Migrate once migration is done.
  ${drush} dis migrate

elif [ "${uri}" = "groups-7.staging.devdrupal.org" ]; then
  # todo remove when the existing front page, "frontpage", does not 404.
  ${drush} variable-set site_frontpage "node"

elif echo "${uri}" | grep -qE "-civicrm.staging.devdrupal.org$|^jobs.devdrupal.org$"; then
  # CiviCRM and Jobs dev sites do not have bakery set up.
  ${drush} pm-disable bakery
fi

# Prime caches for home page and make sure site is basically working.
test_site
