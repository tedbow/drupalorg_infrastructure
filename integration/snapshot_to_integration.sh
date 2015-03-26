# Include common integration script.
. integration/common.sh 'snapshot_to'

# Get the DB name from drush
db=$(${drush} ${type}sql-conf | sed -ne 's/^\s*\[database\] => //p')

# If a snapshot has not been already set in $snapshot, get it from $uri,
# everything before the first '.' or '-'.
[ "${snapshot-}" ] || snapshot=$(echo ${uri} | sed -e 's/[.-].*$//')

# If a snapshot type has been designated, use that. Otherwise, default to
# the 'integration' snapshot.
[ "${snaptype-}" ] || snaptype=integration

if [ "${uri}" != "integration.devdrupal.org" -a "${uri}" != "infrastructure.integration.devdrupal.org" -a "${uri}" != "assoc.integration.devdrupal.org" -a "${uri}" != "events.integration.devdrupal.org" -a "${uri}" != "api.integration.devdrupal.org" -a "${uri}" != "jobs.integration.devdrupal.org" -a "${uri}" != "jobs.devdrupal.org" -a "${uri}" != "qa.integration.devdrupal.org" ] || [ "${suffix-}" == "civicrm" ]; then
  # Copy snapshot.
  rsync -v --copy-links --password-file ~/util.rsync.pass "rsync://integrationmysql@util.drupal.org/mysql-${snaptype}/${snapshot}_database_snapshot.${snaptype}-current.sql.bz2" "${WORKSPACE}"

  # Clear out the DB and import a snapshot.
  (
    echo "DROP DATABASE ${db};"
    echo "CREATE DATABASE ${db};"
    echo "USE ${db};"
    bunzip2 < "${WORKSPACE}/${snapshot}_database_snapshot.${snaptype}-current.sql.bz2"
  ) | ${drush} ${type}sql-cli
else
  ALTDBLOC="/var/www/${uri}/altdb"
  if [ -f ${ALTDBLOC} ]; then
    rm ${ALTDBLOC}
  else
    touch ${ALTDBLOC}
  fi
fi
# Extra preparation for D7.
if [ "${uri}" = "localize-7.integration.devdrupal.org" ]; then
  (
    # OG needs new entity module.
    echo "UPDATE system SET status = 0 WHERE name IN ('og');"
  ) | ${drush} sql-cli
fi

# Clear caches, try updatedb.
if [ "${uri}" != "localize-7.integration.devdrupal.org" ]; then
  ${drush} cc all
fi
${drush} -v updatedb --interactive

if [ "${uri}" = "localize-7.integration.devdrupal.org" ]; then
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

elif [ "${uri}" = "groups-7.integration.devdrupal.org" ]; then
  # todo remove when the existing front page, "frontpage", does not 404.
  ${drush} variable-set site_frontpage "node"

elif echo "${uri}" | grep -qE ".civicrm.devdrupal.org$|^jobs.devdrupal.org$"; then
  # CiviCRM dev sites do not have bakery set up.
  ${drush} pm-disable bakery
fi

# Prime caches for home page and make sure site is basically working.
test_site