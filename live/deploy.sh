# Include common live script.
. live/common.sh 'deploy'

cd ${webroot}
git pull

if [ "${updatedb-}" = "true" ]; then
  ${drush} -v updatedb --interactive
fi
if [ "${civicrm_upgrade_db-}" = "true" ]; then
  ${drush} -v civicrm-upgrade-db
fi
if [ "${cc_menu-}" = "true" ]; then
  ${drush} -v cc "menu"
fi
if [ "${cc_theme-}" = "true" ]; then
  ${drush} -v cc "theme-registry"
fi
if [ "${cc_cssjs-}" = "true" ]; then
  ${drush} -v cc "css-js"
fi
if [ "${cc_views-}" = "true" ]; then
  ${drush} -v cc "views"
fi
if [ "${cc_all-}" = "true" ]; then
  ${drush} -v cc "all"
fi
if [ "${civicrm_cache_clear-}" = "true" ]; then
  ${drush} -v cc civicrm
  ${drush} -v compile-templates
fi
