# Include common staging script.
. staging/common.sh 'snapshot_to'

# Repopulate DB
db=$(${drush} sql-conf | sed -ne 's/^\s*\[database\] => //p')
snapshot=$(echo ${domain} | sed -e 's/\..*$//')
if [ "${domain}" = "staging.devdrupal.org" ] || [ "${domain}" = "7.devdrupal.org" ]; then
  snapshot="drupal"
fi
echo "DROP DATABASE ${db}; CREATE DATABASE ${db};" | ${drush} sql-cli
ssh util bzcat "/var/dumps/mysql/${snapshot}_database_snapshot.staging-current.sql.bz2" | ${drush} sql-cli

# Extra preparation for D7.
if [ "${domain}" = "7.devdrupal.org" ]; then
  # apachesolr causes _node_types_build() to be called before node_update_7000().
  echo "UPDATE system SET status = 0 WHERE name IN ('apachesolr', 'apachesolr_search', 'apachesolr_multisitesearch');" | ${drush} sql-cli
fi

# Log time spent in DB population.
date

# Try updatedb, clear and prime caches
${drush} updatedb -vd
${drush} cc all
wget -O /dev/null http://${domain} --user=drupal --password=drupal
