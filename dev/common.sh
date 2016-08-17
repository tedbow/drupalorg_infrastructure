#!/bin/bash
# Exit immediately on uninitialized variable or error, and print each command.
set -uex

function restart_apache {
  sudo service apache2 restart
  sudo service php5-fpm restart
}

# Set common variables.
vhost_path="/etc/apache2/automated-jenkins/${name}-${site}.conf"
web_path="/var/www/dev/${name}-${site}.dev.devdrupal.org"
# Clean site name, no dots or dashes, truncate to 16 characters.
db_name=$(echo "${name}_${site}" | sed -e "s/[-.]/_/g;s/^\(.\{16\}\).*/\1/")

