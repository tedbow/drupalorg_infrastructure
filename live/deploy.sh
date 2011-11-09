# Set the umask to 0002 so that files are added with 664/-rw-rw-r-- perms
# umask on www1 is defaulting to 0077 for some reason (even though the default is 0022)
umask 0002
cd /var/www/$1/htdocs
bzr update

if [ "$updatedb" = "true" ]; then
  drush updatedb -y
fi
if [ "$civi_updatedb" = "true" ]; then
  drush civicrm-upgrade-db -y
fi
if [ "$cache_clear_theme" = "true" ]; then
  drush cc theme
fi
if [ "$cache_clear_cssjs" = "true" ]; then
  drush cc css+js
fi
if [ "$cache_clear" = "true" ]; then
  drush cc all
fi
