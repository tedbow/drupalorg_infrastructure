#!/bin/bash

# Remove a development environment for a given "name" on stagingvm/stagingdb

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Handle drupal.org vs. sub-domain's properly
if [ ${site} == "drupal.org" ]; then
  site="drupal"
fi
vhost_path="/etc/apache2/vhosts.d/automated-hudson"
web_path="/var/www/dev/${name}-${site}.redesign.devdrupal.org"
db_name=$(echo ${name}_${site} | sed -e "s/-/_/g" -e "s/\./_/g" | sed -e 's/^\(.\{16\}\).*/\1/') # Truncate to 16 chars

if [ ! -e ${web_path} ] || [ ! -e ${vhost_path}/${name}-${site}.conf ]; then
  echo "Cannot find environment for ${name} in ${web_path} or ${vhost_path}/${name}-${site}.conf"
  exit 1
fi

# Delete the webroot
rm -rf ${web_path}

# Delete the vhost
rm -f ${vhost_path}/${name}-${site}.conf

# Drop the database and user
mysql -e "drop database ${db_name};"
mysql -e "revoke all on ${db_name}.* from '${db_name}'@'stagingvm.drupal.org';"

# Restart apache
sudo /etc/init.d/apache2 restart
