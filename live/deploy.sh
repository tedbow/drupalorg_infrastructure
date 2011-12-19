# Include common live script.
. live/common.sh 'deploy'

cd ${webroot}
bzr update

if [ "${updatedb-}" = "true" ];
  ${drush} updatedb
fi
if [ "${civicrm_upgrade_db-}" = "true" ];
  ${drush} civicrm-upgrade-db
fi
if [ "${cc_theme-}" = "true" ];
  ${drush} cc "theme registry"
fi
if [ "${cc_cssjs-}" = "true" ];
  ${drush} cc "css+js"
fi
if [ "${cc_all-}" = "true" ];
  ${drush} cc "all"
fi
