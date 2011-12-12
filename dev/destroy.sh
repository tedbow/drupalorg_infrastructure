#!/bin/bash

# Remove a development environment for a given "name" on stagingvm/stagingdb

# Make sure we have required db info
if [ $# -lt 2 ]; then
  echo "Usage: $0 site name"
  exit 1
fi

# Make sure these exist, otherwise bad things (may) happen
if [ ! $JOB_NAME ] || [ ! $BUILD_TAG ]; then
  echo "\$JOB_NAME or \$BUILD_TAG not defined, make sure to export these variables"
  exit 1
fi

site=$1
name=$2
# Handle drupal.org vs. sub-domain's properly
if [ $1 == "drupal.org" ]; then
  site="drupal"
  fqdn="drupal.org"
  db_site="drupal_redesign"
else
  fqdn="${site}.drupal.org"
  db_site="${site}"
fi
vhost_path="/etc/apache2/vhosts.d/automated-hudson"
web_path="/var/www/dev/${name}-${site}.redesign.devdrupal.org"
db_name=$(echo ${name}_${site} | sed -e "s/-/_/g" -e "s/\./_/g" | sed -e 's/^\(.\{16\}\).*/\1/') # Truncate to 16 chars

if [ ! -e ${web_path} ] || [ ! -e ${vhost_path}/${name}-${site}.conf ]; then
  echo "Cannot find environment for ${name} in ${web_path} or ${vhost_path}/${name}-${site}.conf"
  exit 1
fi

# Delete the webroot
echo "Deleting webroot: ${web_path}"
rm -rf ${web_path}

# Delete the vhost
echo "Deleting vhost: ${vhost_path}/${name}-${site}.conf"
rm -f ${vhost_path}/${name}-${site}.conf

# Drop the database and user
echo "Dropping database and associated user: ${db_name}"
mysql -e "drop database ${db_name};"
mysql -e "revoke all on ${db_name}.* from '${db_name}'@'stagingvm.drupal.org';"

# Restart apache
echo "Restarting Apache"
sudo /etc/init.d/apache2 restart
