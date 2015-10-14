# Exit immediately on uninitialized variable or error, and print each command.
set -uex

function restart_apache {
  sudo /etc/init.d/httpd restart
  sudo /etc/init.d/php-fpm restart
}

# Set common variables.
vhost_path="/etc/httpd/vhosts.d/automated-hudson/${name}-${site}.conf"
web_path="/var/www/dev/${name}-${site}.dev.devdrupal.devdrupal.org"
# Clean DB name, no dots or dashes, truncate to 16 characters.
container_name=$(echo "${name}_${site}" | sed -e "s/[-.]/_/g;s/^\(.\{16\}\).*/\1/")
