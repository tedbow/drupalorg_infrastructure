export PATH=$PATH:/usr/local/bin
export TERM=dumb
domain=$(echo ${JOB_NAME} | sed -e 's/^snapshot_to_//') # denver2012.scratch.drupal.org
drush="drush -r /var/www/${domain}/htdocs -l ${domain} -y"
db=$($drush sql-conf | sed -ne 's/^\s*\[database\] => //p')

# Repopulate DB
echo "DROP DATABASE ${db}; CREATE DATABASE ${db};" | $drush sql-cli
ssh util zcat /var/dumps/mysql/$(echo $domain | sed -e 's/\..*$//')_database_snapshot.staging-current.sql.gz | $drush sql-cli

# todo configure bakery to use staging.drupal.org as a master site
$drush pm-disable bakery

# Prime caches
$drush cc all
wget -O /dev/null http://${domain} --user=drupal --password=drupal
