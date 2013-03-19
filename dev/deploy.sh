# Create a development environment for a given "name" on devwww/devdb

# Include common dev script.
. dev/common.sh

# Usage: write_template "template" "path/to/destination"
function write_template {
  sed -e "s/DB_NAME/${db_name}/g;s/NAME/${name}/g;s/SITE/${site}/g;s/DB_PASS/${db_pass}/g" "dev/${1}" > "${2}"
}

# Fail early if comment is omitted.
[ -z "${COMMENT-}" ] && echo "Comment is required." && exit 1

# Handle drupal.org vs. sub-domains properly
if [ ${site} == "drupal" ]; then
  fqdn="drupal.org"
  repository="drupal.org"
  snapshot="/var/dumps/mysql/drupal_database_snapshot.reduce-current.sql.bz2"
elif [ ${site} == "drupal_7" ]; then
  fqdn="drupal.org"
  repository="drupal.org-7"
  snapshot="/var/dumps/mysql/drupal_7_database_snapshot.reduce-current.sql.bz2"
else
  # Strip any _ and following characters from ${site}, and add .drupal.org.
  # Such as 'qa_7' -> 'qa.drupal.org'
  fqdn="$(echo "${site}" | sed -e 's/_.*//').drupal.org"
  # If ${site} has an underscore, use the following characters. Such as
  # 'qa_7' -> 'qa.drupal.org-7'
  repository="${fqdn}$(echo ${site} | sed -ne 's/.*_/-/p')"
  snapshot="/var/dumps/mysql/${site}_database_snapshot.dev-current.sql.bz2"
fi

# DrupalCon São Paulo 2012 and later have a common BZR repository.
if [ "${site}" == "saopaulo2012" -o "${site}" == "sydney2013" -o "${site}" == "portland2013" -o "${site}" == "europe2014" -o "${site}" == "northamerica2014" ]; then
  repository="drupalcon-7"
fi

# Sites migrated to D7.
if [ "${site}" == "association" -o "${site}" == "api" ]; then
  repository="${repository}-7"
fi

export TERM=dumb
drush="drush -r ${web_path}/htdocs -y"
db_pass=$(pwgen -s 16 1)

[ -e "${web_path}" ] && echo "Project webroot already exists!" && exit 1

# Create the webroot and add comment file
mkdir -p "${web_path}/htdocs"
chown -R bender:developers "${web_path}"
echo "${COMMENT}" > "${web_path}/comment"

# Create the vhost config
write_template "vhost.conf.template" "${vhost_path}"

# Configure the database
mysql -e "CREATE DATABASE ${db_name};"
mysql -e "GRANT ALL ON ${db_name}.* TO '${db_name}'@'devwww.drupal.org' IDENTIFIED BY '${db_pass}';"

# Checkout webroot 
echo "Populating development environment with bzr checkout"
bzr checkout bzr+ssh://util.drupal.org/bzr/${repository} "${web_path}/htdocs"

# Add settings.local.php
write_template "settings.local.php.template" "${web_path}/htdocs/sites/default/settings.local.php"

# Strongarm the permissions
echo "Forcing proper permissions on ${web_path}"
find "${web_path}" -type d -exec chmod g+rwx {} +
find "${web_path}" -type f -exec chmod g+rw {} +
chgrp -R developers "${web_path}"

# Import database
ssh util cat "${snapshot}" | bunzip2 | mysql "${db_name}"
# InnoDB handles the url alias table much faster.
echo "ALTER TABLE url_alias ENGINE InnoDB;" | ${drush} sql-cli

# Disable modules that don't work well in development (yet)
${drush} pm-disable paranoia
${drush} pm-disable civicrm
${drush} pm-disable securepages

# Link up the files directory
ln -s /media/${fqdn} "${web_path}/htdocs/$(${drush} status | sed -ne 's/^ *File directory path *: *\([^ ]*\).*$/\1/p')"

# Reload apache with new vhost
restart_apache

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
