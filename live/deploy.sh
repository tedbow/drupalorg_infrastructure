# Include common live script.
. live/common.sh 'deploy'

cd ${webroot}
# Added by bdragon for debugging qa.drupal.org misdeploy.
bzr status
bzr update

if [ "${updatedb-}" = "true" ]; then
  ${drush} updatedb
fi
if [ "${civicrm_upgrade_db-}" = "true" ]; then
  ${drush} civicrm-upgrade-db
fi
if [ "${cc_menu-}" = "true" ]; then
  ${drush} cc "menu"
fi
if [ "${cc_theme-}" = "true" ]; then
  ${drush} cc "theme registry"
fi
if [ "${cc_cssjs-}" = "true" ]; then
  ${drush} cc "css+js"
fi
if [ "${cc_all-}" = "true" ]; then
  ${drush} cc "all"
fi
