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
  ssh util cat "/var/dumps/mysql/${snapshot}_database_snapshot.staging-current.sql.bz2" | bunzip2
) | ${drush} ${type}sql-cli

# Extra preparation for D7.
if [ "${uri}" = "7.devdrupal.org" ]; then
  (
    # Apache Solr causes _node_types_build() to be called before node_update_7000().
    # Project Issue and Versioncontrol are not ready yet
    echo "UPDATE system SET status = 0 WHERE name IN ('apachesolr', 'apachesolr_search', 'apachesolr_multisitesearch');"
  ) | ${drush} sql-cli
elif [ "${uri}" = "localize.7.devdrupal.org" ]; then
  (
    # OG needs new entity module.
    echo "UPDATE system SET status = 0 WHERE name IN ('og');"
  ) | ${drush} sql-cli
fi

# Log time spent in DB population.
date

# Try updatedb, clear caches.
${drush} updatedb --interactive
${drush} cc all

if [ "${uri}" = "localize.7.devdrupal.org" ]; then
  # OG needs to migrate data.
  ${drush} en og_migrate
  ${drush} og-migrate
  ${drush} dis og_migrate
fi

# Prime caches for home page and make sure site is basically working.
wget -O /dev/null http://${uri} --user=drupal --password=drupal
