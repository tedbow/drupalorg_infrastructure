#!/bin/bash

# Create a development environment for a given "name" on stagingvm/stagingdb

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Handle drupal.org vs. sub-domains properly
if [ ${site} == "drupal" ]; then
  site="drupal"
  fqdn="drupal.org"
  snapshot="/var/dumps/mysql/drupal_database_snapshot.reduce-current.sql.gz"
else
  fqdn="${site}.drupal.org"
  snapshot="/var/dumps/mysql/${site}_database_snapshot-current.sql.gz"
fi
vhost_path="/etc/apache2/vhosts.d/automated-hudson"
template="template-generic"
web_path="/var/www/dev/${name}-${site}.redesign.devdrupal.org"
export TERM=dumb
drush="/usr/local/bin/drush -r ${web_path}/htdocs -l ${fqdn}"
db_name=$(echo ${name}_${site} | sed -e "s/-/_/g" -e "s/\./_/g" | sed -e 's/^\(.\{16\}\).*/\1/') # Truncate to 16 chars
db_pass=$(pwgen -s 16 1)
settings_template="/var/www/dev/settings.local.template-generic"
user_passwd=$(pwgen -s 16 1)

[ -e "${web_path}" ] && echo "Project webroot already exists!" && exit 1

# Create the webroot and add comment file
echo "Creating webroot and comment file"
mkdir -p ${web_path}/htdocs
chown -R bender:developers ${web_path}
echo "${COMMENT}" > ${web_path}/comment
echo "" >> ${web_path}/comment
echo "db user/pass: ${db_name}/${db_pass}" >> ${web_path}/comment
echo "db name: ${db_name}" >> ${web_path}/comment

# Create the vhost config
echo "Creating vhost configuration: ${vhost_path}/${name}-${site}.conf"
sed -e "s/NAME/${name}/g" -e "s/SITE/${site}/g" ${vhost_path}/${template} > ${vhost_path}/${name}-${site}.conf

# Configure the database
echo "Configuring the database"
mysql -e "create database ${db_name};"
mysql -e "grant all on ${db_name}.* to '${db_name}'@'stagingvm.drupal.org' identified by '${db_pass}';"

# Checkout webroot 
echo "Populating development environment with bzr checkout"
bzr checkout bzr+ssh://util.drupal.org/bzr/${fqdn} ${web_path}/htdocs

# Add settings.local.php
sed -e "s/DB_NAME/${db_name}/g" -e "s/NAME/${name}/g" -e "s/SITE/${site}/g" -e "s/PASS/${db_pass}/g" ${settings_template} > ${web_path}/htdocs/sites/default/settings.local.php
echo "<?php
\$options['uri'] = 'http://${name}-${site}.redesign.devdrupal.org';" > ${web_path}/htdocs/drushrc.php

# Strongarm the permissions
echo "Forcing proper permissions on ${web_path}"
find ${web_path} -type d -exec chmod g+rwx {} +
find ${web_path} -type f -exec chmod g+rw {} +
chgrp -R developers ${web_path}

# Import mysql database
echo "Importing latest database snapshot"
ssh util zcat ${snapshot} | mysql ${db_name}
echo "Setting all drupal user passwords to ${user_passwd}"
mysql -e "UPDATE users SET pass = MD5('${user_passwd}')" ${db_name} 
echo "User password: ${user_passwd}" >> ${web_path}/comment

# Disable modules that don't work well in development (yet)
${drush} pm-disable paranoia -y
${drush} pm-disable civicrm -y

# Link up the files directory
ln -s /media/${fqdn} ${web_path}/htdocs/$(${drush} status | sed -ne 's/^ *File directory path *: *//p')

# Reload apache with new vhost
echo "Restarting Apache"
sudo /etc/init.d/apache2 restart

# Get ready for development
echo 1 | ${drush} vdel cache
${drush} vdel preprocess_css -y
${drush} vdel preprocess_js -y
${drush} pm-enable -y views_ui
${drush} pm-enable -y imagecache_ui

# Set up for potential bakery testing
${drush} vdel bakery_slaves -y
${drush} vset bakery_domain ".redesign.devdrupal.org" -y
if [ "${site}" == "drupal" ]; then
  # Drupal.org sites are masters
  ${drush} vset bakery_master "${name}-${site}.redesign.devdrupal.org" -y
  ${drush} vset bakery_key "$(pwgen -s 32 1)" -y
else
  if [ "${bakery_master}" ]; then
    # Hook up to a Drupal.org
    ${drush} vset bakery_master "http://${bakery_master}-drupal.redesign.devdrupal.org/" -y
    drush_master="/usr/local/bin/drush -r /var/www/dev/${bakery_master}-drupal.redesign.devdrupal.org/htdocs -l ${bakery_master}-drupal.redesign.devdrupal.org"
    ${drush} vset bakery_key $(${drush_master} vget bakery_key | sed -ne 's/^.*"\(.*\)"/\1/p') -y
    ${drush_master} bakery-add-slave "http://${name}-${site}.redesign.devdrupal.org/" -y
  else
    # Don't bother with bakery
    ${drush} pm-disable bakery -y
  fi
fi

# Prime any big caches
wget -O /dev/null http://${name}-${site}.redesign.devdrupal.org --user=drupal --password=drupal
