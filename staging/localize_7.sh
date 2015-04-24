# Extra preparation for D7.
function localize_7_pre_update {
  (
    # OG needs new entity module.
    echo "UPDATE system SET status = 0 WHERE name IN ('og');"
  ) | ${drush} sql-cli
}

function localize_7_post_update {
  # Set the flag for OG to have global group roles
  ${drush} variable-set og_7000_access_field_default_value 0

  # Enable required modules.
  ${drush} en og_context og_ui migrate

  # Display a birdview of OG migration and migrate data.
  ${drush} ms
  ${drush} mi --all

  # Revert view og_members_ldo.
  ${drush} views-revert og_members_ldo

  # Disable Migrate once migration is done.
  ${drush} dis migrate
}
