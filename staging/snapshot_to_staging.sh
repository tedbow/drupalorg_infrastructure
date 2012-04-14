# Include common staging script.
. staging/common.sh 'snapshot_to'

# Repopulate DB
db=$(${drush} sql-conf | sed -ne 's/^\s*\[database\] => //p')
snapshot=$(echo ${domain} | sed -e 's/\..*$//')
if [ "${domain}" = "staging.devdrupal.org" ] || [ "${domain}" = "7.devdrupal.org" ]; then
  snapshot="drupal"
fi
echo "DROP DATABASE ${db}; CREATE DATABASE ${db};" | ${drush} sql-cli
ssh util zcat "/var/dumps/mysql/${snapshot}_database_snapshot.staging-current.sql.gz" | ${drush} sql-cli

# Try updatedb, clear and prime caches
${drush} updatedb
${drush} cc all
wget -O /dev/null http://${domain} --user=drupal --password=drupal
