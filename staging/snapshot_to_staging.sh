# Include common staging script.
. staging/common.sh 'snapshot_to'

# Get the DB name from drush
db=$(${drush} ${type}sql-conf | sed -ne 's/^\s*\[database\] => //p')

# If a snapshot has not been already set in $snapshot, get it from $uri,
# everything before the first '.'
[ "${snapshot-}" ] || snapshot=$(echo ${uri} | sed -e 's/\..*$//')

# If a snapshot type has been designated, use that. Otherwise, default to
# the 'staging' snapshot.
[ "${snaptype-}" ] || snaptype=staging

# Clear out the DB and import a snapshot.
(
  echo "DROP DATABASE ${db};"
  echo "CREATE DATABASE ${db};"
  echo "USE ${db};"
  ssh util cat "/var/dumps/mysql/${snapshot}_database_snapshot.${snaptype}-current.sql.bz2" | bunzip2
) | ${drush} ${type}sql-cli

# Extra preparation for D7.
if [ "${uri}" = "7.devdrupal.org" ]; then
  (
    # Ported features containing fields that content_migrate touch need to be migrated with the feature disabled to
    # prevent data from going missing. (Presumably.)
    #echo "UPDATE system SET status = 0 WHERE name IN ('project_solr', 'drupalorg_search', 'features');"
    echo "UPDATE system SET status = 0 WHERE name = 'features';"
    # Officially associate the "Projects" vocabulary with projects -- it was being altered in in a hacky way, and taxonomy upgrade
    # thought it was unused.
    echo "INSERT IGNORE INTO vocabulary_node_types (vid, type) VALUES (3, 'project_project');"
  ) | ${drush} sql-cli


elif [ "${uri}" = "localize.7.devdrupal.org" ]; then
  (
    # OG needs new entity module.
    echo "UPDATE system SET status = 0 WHERE name IN ('og');"
  ) | ${drush} sql-cli
fi

# Try updatedb, clear caches.
${drush} -v updatedb --interactive
#${drush} -v updatedb --interactive || echo "SOME UPDATES FAILED BUT CONTINUING ANYWAY!!!!!!"
${drush} cc all

if [ "${uri}" = "7.devdrupal.org" ]; then
  # Do cck fields migration. (Fieldgroups, etc.)
  ${drush} en field_group
  ${drush} en content_migrate
  # Hack to try and convince drush to recognize the new commands.
  ${drush} dis content_migrate
  ${drush} en content_migrate
  # When prod is on 5.4 drush we can use this instead of all.
  #${drush} cc drush
  ${drush} cc all

  # Show current status for debugging purposes.
  ${drush} content-migrate-status

  # Manual migration for data. Blame features.
  ${drush} content-migrate-field-data field_book_description || true
  ${drush} content-migrate-field-data field_book_isbn_10 || true
  ${drush} content-migrate-field-data field_book_isbn_13 || true
  ${drush} content-migrate-field-data field_book_listing_authors || true
  ${drush} content-migrate-field-data field_book_listing_date || true
  ${drush} content-migrate-field-data field_book_page_count || true
  ${drush} content-migrate-field-data field_book_purchase_link || true
  ${drush} content-migrate-field-data field_book_subtitle || true
  ${drush} content-migrate-field-data field_cover_image || true
  ${drush} content-migrate-field-data field_official_website || true
  ${drush} content-migrate-field-data field_publisher || true
  ${drush} content-migrate-field-data field_community || true
  ${drush} content-migrate-field-data field_goals || true
  ${drush} content-migrate-field-data field_developed || true
  ${drush} content-migrate-field-data field_developed_org || true
  ${drush} content-migrate-field-data field_images || true
  ${drush} content-migrate-field-data field_link || true
  ${drush} content-migrate-field-data field_main_image || true
  ${drush} content-migrate-field-data field_module || true
  ${drush} content-migrate-field-data field_module_selection || true
  ${drush} content-migrate-field-data field_overview || true
  ${drush} content-migrate-field-data field_profiles || true
  ${drush} content-migrate-field-data field_status || true
  ${drush} content-migrate-field-data field_coder_recorded || true
  ${drush} content-migrate-field-data field_coder_update_recorded || true
  ${drush} content-migrate-field-data field_examples_recorded || true
  ${drush} content-migrate-field-data field_change_to || true
  ${drush} content-migrate-field-data field_change_to_branch || true
  ${drush} content-migrate-field-data field_description || true
  ${drush} content-migrate-field-data field_impacts || true
  ${drush} content-migrate-field-data field_issues || true
  ${drush} content-migrate-field-data field_module_recorded || true
  ${drush} content-migrate-field-data field_online_recorded || true
  ${drush} content-migrate-field-data field_other_details || true
  ${drush} content-migrate-field-data field_other_recorded || true
  ${drush} content-migrate-field-data field_project || true
  ${drush} content-migrate-field-data field_theme_recorded || true
  ${drush} content-migrate-field-data field_update_progress || true
  ${drush} content-migrate-field-data field_budget || true
  ${drush} content-migrate-field-data field_contributions || true
  ${drush} content-migrate-field-data field_logo || true
  ${drush} content-migrate-field-data field_organization_headquarters || true
  ${drush} content-migrate-field-data field_organization_hosting_categ || true
  ${drush} content-migrate-field-data field_organization_hosting_level || true
  ${drush} content-migrate-field-data field_organization_hosting_url || true
  ${drush} content-migrate-field-data field_organization_marketplace || true
  ${drush} content-migrate-field-data field_organization_training_desc || true
  ${drush} content-migrate-field-data field_organization_training_list || true
  ${drush} content-migrate-field-data field_organization_training_url || true
  ${drush} content-migrate-field-data field_org_marketplace_request || true
  ${drush} content-migrate-field-data field_organization_issue || true
  ${drush} content-migrate-field-data field_org_training_issue || true

  # Migrate all fields.
  ${drush} content-migrate-fields
  ${drush} cc all

  ${drush} en features
  ${drush} fra
  # Re-enable & revert features. (disabled until the features are converted to
  # D7.)
  # ${drush} en drupalorg_change_notice
  # ${drush} fra

  # Do project issue import
  ${drush} en migrate_ui
  ${drush} cc all
  ${drush} ms
  ${drush} mi ProjectIssueFixInitFiles
  ${drush} mi ProjectIssueRethreadIssueFollowups
  ${drush} mi ProjectIssueTimelinePhaseOne
  ${drush} mi ProjectIssueTimelinePhaseTwo
  ${drush} mi ProjectIssueTimelinePhaseThree
  ${drush} mi ProjectIssueAllocateVids
  ${drush} mi ProjectIssueAllocateCids
  ${drush} mi ProjectIssueRebuildCommentFields
  ${drush} mi ProjectIssueRebuildNodeFields
  #${drush} mi ProjectIssuePhaseTwo
  ${drush} mi ProjectIssueFixGenericCorruption

  ${drush} dis content_migrate

  ${drush} en conflict

  # https://drupal.org/node/1830028
  ${drush} association-members || echo "Association members failed but continuing anyway!"

  # Reenable drupal.org search.
  ${drush} en drupalorg_search
  # Force the system to notice the facets.
  ${drush} cc all

elif [ "${uri}" = "localize.7.devdrupal.org" ]; then
  # Enable required modules.
  ${drush} en og_context og_ui migrate

  # Display a birdview of OG migration and migrate data.
  ${drush} ms
  ${drush} mi --all

  # Revert view og_members_ldo.
  ${drush} views-revert og_members_ldo

  # Disable Migrate once migration is done.
  ${drush} dis migrate

elif echo "${uri}" | grep -q ".civicrm.devdrupal.org$"; then
  # CiviCRM dev sites do not have bakery set up.
  ${drush} pm-disable bakery
fi

# Prime caches for home page and make sure site is basically working.
test_site
