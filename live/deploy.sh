# Set the umask to 0002 so that files are added with 664/-rw-rw-r-- perms
# umask on www1 is defaulting to 0077 for some reason (even though the default is 0022)
umask 0002
cd /var/www/$1/htdocs
bzr update

[ "$updatedb" = "true" ] && drush updatedb -y
[ "$civicrm_upgrade_db" = "true" ] && drush civicrm-upgrade-db -y
[ "$cc_theme" = "true" ] && drush cc "theme registry"
[ "$cc_cssjs" = "true" ] && drush cc "css+js"
[ "$cc_all" = "true" ] && drush cc "all"
