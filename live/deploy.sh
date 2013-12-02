# Include common live script.
. live/common.sh 'deploy'

cd ${webroot}
bzr update

if [ "${updatedb-}" = "true" ]; then
  ${drush} -v updatedb --interactive
fi
if [ "${civicrm_upgrade_db-}" = "true" ]; then
  ${drush} civicrm-upgrade-db
fi
if [ "${cc_menu-}" = "true" ]; then
  ${drush} cc "menu"
fi
if [ "${cc_theme-}" = "true" ]; then
  ${drush} cc "theme-registry"
fi
if [ "${cc_cssjs-}" = "true" ]; then
  ${drush} cc "css-js"
fi
if [ "${cc_views-}" = "true" ]; then
  ${drush} cc "views"
fi
if [ "${cc_all-}" = "true" ]; then
  ${drush} cc "all"
fi
if [ "${civicrm_cache_clear-}" = "true" ]; then
  ${drush} cc civicrm
  ${drush} compile-templates
fi
