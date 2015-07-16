# Extra preparation for D7.
function localize_7_pre_update {
  (
    # OG needs new entity module.
    echo "UPDATE system SET status = 0 WHERE name IN ('og','og_ui', 'og_context');"
  ) | ${drush} sql-cli
}

function localize_7_post_update {
  # Set the flag for OG to have global group roles
  ${drush} variable-set og_7000_access_field_default_value 0

  # Set the installation profile
  ${drush} variable-set install_profile minimal

  # Enable required modules.
  ${drush} en og og_context og_ui migrate localizedrupalorg localizedrupalorg_groups localizedrupalorg_permissions localizedrupalorg_polls localizedrupalorg_stories localizedrupalorg_users localizedrupalorg_wikis

  # Display a birdview of OG migration and migrate data.
  ${drush} ms
  ${drush} mi --all

  # Revert view og_members_ldo.
  #${drush} views-revert og_members_ldo

  # Disable Migrate once migration is done.
  ${drush} dis migrate

  # Enable Admin menu and related modules and disable seven theme
  ${drush} en admin_menu adminimal adminimal_admin_menu
  ${drush} dis seven

  # Rebuild Registry and upgrade
  ${drush} rr
  ${drush} updb
}
