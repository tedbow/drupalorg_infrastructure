# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Allow group-writable files.
umask g+w

# Get the domain name by stripping deploy_ from front of the job name.
domain=$(echo ${JOB_NAME} | sed -e 's/^snapshot_to_//')

# For easily executing Drush.
export TERM=dumb
drush="drush -r /var/www/${domain}/htdocs -l ${domain} -y"

# Repopulate DB
db=$($drush sql-conf | sed -ne 's/^\s*\[database\] => //p')
echo "DROP DATABASE ${db}; CREATE DATABASE ${db};" | $drush sql-cli
ssh util zcat /var/dumps/mysql/$(echo $domain | sed -e 's/\..*$//')_database_snapshot.staging-current.sql.gz | $drush sql-cli

# todo configure bakery to use staging.drupal.org as a master site
$drush pm-disable bakery

# Try updatedb, clear and prime caches
$drush updatedb
$drush cc all
wget -O /dev/null http://${domain} --user=drupal --password=drupal
