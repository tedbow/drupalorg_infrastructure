# Include common staging script.
. staging/common.sh 'snapshot_to'

# Get the DB name from drush
db=$(${drush} ${type}sql-conf | sed -ne 's/^\s*\[database\] => //p')

# If a snapshot has not been already set in $snapshot, get it from $uri,
# everything before the first '.'
[ "${snapshot-}" ] || snapshot=$(echo ${uri} | sed -e 's/\..*$//')

# Clear out the DB and import a snapshot.
(
  echo "DROP DATABASE ${db};"
  echo "CREATE DATABASE ${db};"
  echo "USE ${db};"
  ssh util bzcat "/var/dumps/mysql/${snapshot}_database_snapshot.staging-current.sql.bz2"
) | ${drush} ${type}sql-cli

# Extra preparation for D7.
if [ "${uri}" = "7.devdrupal.org" ]; then
  (
    # Apache Solr causes _node_types_build() to be called before node_update_7000().
    # Project Issue and Versioncontrol are not ready yet
    echo "UPDATE system SET status = 0 WHERE name IN ('apachesolr', 'apachesolr_search', 'apachesolr_multisitesearch', 'project_issue', 'versioncontrol');"
    # Bypass 6.x versioncontrol updates. Remove with #1568176.
    echo "UPDATE system SET schema_version = 6322 WHERE name = 'versioncontrol';"
  ) | ${drush} sql-cli
fi

# Log time spent in DB population.
date

# Try updatedb, clear and prime caches
${drush} updatedb -vd
${drush} cc all
wget -O /dev/null http://${uri} --user=drupal --password=drupal
