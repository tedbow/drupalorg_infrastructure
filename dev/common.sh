# Exit immediately on uninitialized variable or error, and print each command.
set -uex

function restart_apache {
  sudo /etc/init.d/apache2 restart
}

# Set common variables.
vhost_path="/etc/apache2/vhosts.d/automated-hudson/${name}-${site}.conf"
web_path="/var/www/dev/${name}-${site}.redesign.devdrupal.org"
# Clean DB name, no dots or dashes, truncate to 16 characters.
db_name=$(echo "${name}_${site}" | sed -e "s/[-.]/_/g;s/^\(.\{16\}\).*/\1/")
