# Extra preparation for D7.
function localize_7_pre_update {
  (
    # OG needs new entity module.
    echo "UPDATE system SET status = 0 WHERE name IN ('og','og_ui', 'og_context', 'localizedrupalorg', 'l10n_community', 'l10n_drupal', 'l10n_drupal_rest', 'l10n_groups', 'l10n_packager', 'l10n_pconfig', 'l10n_remote', 'l10n_server');"
  ) | ${drush} sql-cli
}

function localize_7_post_update {
  # Set the installation profile.
  ${drush} variable-set install_profile minimal

  # Enable the post D7 upgrade modules.
  ${drush} en og og_context og_ui migrate migrate_ui diff l10n_community l10n_drupal l10n_drupal_rest l10n_groups l10n_packager l10n_pconfig l10n_remote l10n_server localizedrupalorg
  ${drush} rr
  ${drush} en admin_menu adminimal adminimal_admin_menu contextual

  # run some post updates on the localizeddrupalorg module.
  (
    echo "UPDATE system SET schema_version = 7101 WHERE name='localizedrupalorg'";
  ) | ${drush} sql-cli

  ${drush} updb --interactive
  ${drush} cc all

  # Prepare migrator
  ${drush} cc drush
  ${drush} ms --refresh

  # migrate some things!
  ${drush} mi OgMigrateAddFields
  ${drush} mi ogmigrategroupl10n_group
  ${drush} mi OgUiMigrateAddField
  ${drush} mi oguipopulatefieldl10n_group

  #migrate the rest
  ${drush} mi OgMigrateOgurRoles
  ${drush} mi OgMigrateUser
  ${drush} mi OgMigrateOgur
  ${drush} mi OgMigrateContent

  #post user migrate LDO steps
  ${drush} ldo-ogb
  ${drush} ldo-mcd
  ${drush} ldo-abr

  # Add the features last, after migration
  ${drush} en localizedrupalorg_groups localizedrupalorg_permissions localizedrupalorg_polls localizedrupalorg_stories localizedrupalorg_users localizedrupalorg_wikis
  ${drush} ldo-fr

  # Disable and uninstall migrate
  ${drush} dis migrate_ui migrate
  ${drush} pm-uninstall migrate_ui migrate
}
