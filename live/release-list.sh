#!/usr/bin/env bash

# This is all releases, not projects that are tagged, not including -dev
# releases, ordered by release date. A stopgap for localize.drupal.org's needs
# for https://drupal.org/node/669910.

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

drush -r /var/www/drupal.org/htdocs -l drupal.org sql-cli > /var/www/drupal.org/htdocs/files/releases.tsv <<end
  CHARSET utf8;
  SELECT
    from_unixtime(n.created) AS created,
    pm.field_project_machine_name_value AS project_machine_name,
    rv.field_release_version_value AS version,
    td.name AS api,
    np.title AS project_name
  FROM node n
  INNER JOIN field_data_field_release_project rp ON rp.entity_id = n.nid
  INNER JOIN field_data_field_release_build_type rbt ON rbt.entity_id = n.nid AND rbt.field_release_build_type_value = 'static'
  INNER JOIN field_data_field_release_version rv ON rv.entity_id = n.nid
  INNER JOIN field_data_field_project_machine_name pm ON pm.entity_id = rp.field_release_project_target_id
  INNER JOIN field_data_taxonomy_vocabulary_6 ra ON ra.entity_id = n.nid
  INNER JOIN taxonomy_term_data td ON td.tid = ra.taxonomy_vocabulary_6_tid
  INNER JOIN node np ON rp.field_release_project_target_id = np.nid
  WHERE n.status = 1
  ORDER BY n.created DESC;
end
