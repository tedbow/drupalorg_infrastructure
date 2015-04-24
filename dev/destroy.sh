# Remove a development environment for a given "name" on devwww/devdb

# Include common dev script.
. dev/common.sh

if [ ! -e "${web_path}" ] || [ ! -e "${vhost_path}" ]; then
  echo "Cannot find environment for ${name} in ${web_path} or ${vhost_path}"
  exit 1
fi

# Delete the webroot
sudo rm -rf "${web_path}"

# Delete the vhost
rm -f "${vhost_path}"

# Drop the database and user
mysql <<end
  DROP DATABASE ${db_name};
  REVOKE ALL ON ${db_name}.* FROM '${db_name}'@'devwww1.drupal.aws';
  DROP USER '${db_name}'@'devwww1.drupal.aws';
end

restart_apache
