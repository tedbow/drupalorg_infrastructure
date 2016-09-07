#!/bin/bash
# Remove a development environment for a given "name" on devwww2

# Include common dev script.
. pvtdev/common.sh

if [ ! -e "${web_path}" ] || [ ! -e "${vhost_path}" ]; then
  echo "Cannot find environment for ${name} in ${web_path} or ${vhost_path}"
  exit 1
fi

# Delete the webroot
sudo rm -rf "${web_path}"

# Delete the vhost
sudo rm -f "${vhost_path}"

# Drop the database and user
mysql <<end
  DROP DATABASE ${db_name};
  REVOKE ALL ON ${db_name}.* FROM '${db_name}'@'wwwpvtdev1.drupal.bak';
  DROP USER '${db_name}'@'wwwpvtdev1.drupal.bak';
end

restart_apache
