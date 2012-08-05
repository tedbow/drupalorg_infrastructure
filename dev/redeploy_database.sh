# Reset the database on an existing development environment on devwww/devdb.

# Include common dev script.
. dev/common.sh

# Handle drupal.org vs. sub-domains properly
if [ ${site} == "drupal" ]; then
  snapshot="/var/dumps/mysql/drupal_database_snapshot.reduce-current.sql.bz2"
elif [ ${site} == "drupal_7" ]; then
  snapshot="/var/dumps/mysql/drupal_7_database_snapshot.reduce-current.sql.bz2"
else
  snapshot="/var/dumps/mysql/${site}_database_snapshot.dev-current.sql.bz2"
fi

export TERM=dumb
drush="drush -r ${web_path}/htdocs -y"

# Reset the database.
mysql -e "DROP DATABASE ${db_name};"
mysql -e "CREATE DATABASE ${db_name};"

# Import database
ssh util cat "${snapshot}" | bunzip2 | mysql "${db_name}"

# Disable modules that don't work well in development (yet)
${drush} pm-disable paranoia
${drush} pm-disable civicrm

# Get ready for development
${drush} vset cache 0
${drush} vdel preprocess_css
${drush} vdel preprocess_js
${drush} pm-enable devel
${drush} pm-enable views_ui
${drush} pm-enable imagecache_ui

${drush} updatedb

# Enable UC test gateway
${drush} en test_gateway
${drush} vset uc_payment_credit_gateway test_gateway

# Set up for potential bakery testing
${drush} vdel bakery_slaves
${drush} vset bakery_domain ".redesign.devdrupal.org"
if [ "${site}" == "drupal" ]; then
  # Drupal.org sites are masters
  ${drush} vset bakery_master "http://${name}-${site}.redesign.devdrupal.org/"
  ${drush} vset bakery_key "$(pwgen -s 32 1)"
else
  if [ "${bakery_master-}" ]; then
    # Hook up to a Drupal.org
    ${drush} vset bakery_master "http://${bakery_master}-drupal.redesign.devdrupal.org/"
    drush_master="drush -r /var/www/dev/${bakery_master}-drupal.redesign.devdrupal.org/htdocs -l ${bakery_master}-drupal.redesign.devdrupal.org -y"
    ${drush} vset bakery_key $(${drush_master} vget bakery_key | sed -ne 's/^.*"\(.*\)"/\1/p')
    ${drush_master} bakery-add-slave "http://${name}-${site}.redesign.devdrupal.org/"
  else
    # Don't bother with bakery
    ${drush} pm-disable bakery
  fi
fi

# Set up test user
${drush} upwd bacon --password=bacon

# Prime any big caches
wget -O /dev/null http://${name}-${site}.redesign.devdrupal.org --user=drupal --password=drupal
