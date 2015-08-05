# Extra preparation for D7.
function localize_7_pre_update {
  (
    # OG needs new entity module.
    echo "UPDATE system SET status = 0 WHERE name IN ('og','og_ui', 'og_context', 'localizedrupalorg', 'l10n_community', 'l10n_drupal', 'l10n_drupal_rest', 'l10n_groups', 'l10n_packager', 'l10n_pconfig', 'l10n_remote', 'l10n_server');"
  ) | ${drush} sql-cli
}

function localize_7_post_update {
  # Set the installation profile
  ${drush} variable-set install_profile minimal

  # Do not try getting projects from Drupal.org's DB.
  ${drush} variable-delete l10n_server_connector_l10n_project_drupalorg_cron

  # Enable required modules.
  ${drush} en og og_context og_ui migrate migrate_ui diff l10n_community l10n_drupal l10n_drupal_rest l10n_groups l10n_packager l10n_pconfig l10n_remote l10n_server localizedrupalorg localizedrupalorg_groups localizedrupalorg_permissions localizedrupalorg_polls localizedrupalorg_stories localizedrupalorg_users localizedrupalorg_wikis

  # Rebuild Registry
  ${drush} rr

  # Enable Admin menu and related modules and disable seven theme
  ${drush} en admin_menu adminimal adminimal_admin_menu

  # Setup localizedrupalorg module to be ready to be updated later
  (
    echo "UPDATE system SET schema_version = 7101 WHERE name='localizedrupalorg'";
  ) | drush sql-cli
}
