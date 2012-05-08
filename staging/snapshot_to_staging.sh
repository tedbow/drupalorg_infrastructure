# Include common staging script.
. staging/common.sh 'snapshot_to'

# Clear out DB
db=$(${drush} ${type}sql-conf | sed -ne 's/^\s*\[database\] => //p')
echo "DROP DATABASE ${db}; CREATE DATABASE ${db};" | ${drush} ${type}sql-cli

# If a snapshot has not been already set in $snapshot, get it from $uri,
# everything before the first '.'
[ "${snapshot-}" ] || snapshot=$(echo ${uri} | sed -e 's/\..*$//')

# Import the snapshot to the DB.
ssh util bzcat "/var/dumps/mysql/${snapshot}_database_snapshot.staging-current.sql.bz2" | ${drush} ${type}sql-cli

# Extra preparation for D7.
if [ "${uri}" = "7.devdrupal.org" ]; then
  # apachesolr causes _node_types_build() to be called before node_update_7000().
  echo "UPDATE system SET status = 0 WHERE name IN ('apachesolr', 'apachesolr_search', 'apachesolr_multisitesearch');" | ${drush} sql-cli
fi

# Log time spent in DB population.
date

# Try updatedb, clear and prime caches
${drush} updatedb -vd
${drush} cc all
wget -O /dev/null http://${uri} --user=drupal --password=drupal
