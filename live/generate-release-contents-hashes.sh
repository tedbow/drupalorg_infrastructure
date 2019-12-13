#!/bin/bash

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Get list of all published releases with a .tar.gz file, not -core.tar.gz
# files from distributions.
echo "SELECT DISTINCT fdf_pmn.field_project_machine_name_value, fdf_rv.field_release_version_value FROM node n INNER JOIN field_data_field_release_build_type fdf_rbt ON fdf_rbt.entity_id = n.nid AND fdf_rbt.field_release_build_type_value = 'static' INNER JOIN field_data_field_release_files fdf_rf ON fdf_rf.entity_id = n.nid INNER JOIN field_data_field_release_file fdf_f ON fdf_f.entity_id = fdf_rf.field_release_files_value INNER JOIN file_managed fm ON fm.fid = fdf_f.field_release_file_fid AND fm.filename REGEXP '\\.tar\\.gz$' AND fm.filename NOT REGEXP '-core\\.tar\\.gz$' INNER JOIN field_data_field_release_version fdf_rv ON fdf_rv.entity_id = n.nid INNER JOIN field_data_field_release_project fdf_rp ON fdf_rp.entity_id = n.nid INNER JOIN field_data_field_project_machine_name fdf_pmn ON fdf_pmn.entity_id = fdf_rp.field_release_project_target_id WHERE n.status = 1" | drush -r /var/www/drupal.org/htdocs sql-cli --extra='--skip-column-names' | sort | sed -e 's/\t/ /' > releases.txt

# Filter by project.
[ -z "${project}" ] && sed --in-place -n -e "/^${project} /p" releases.txt

# Get list of package contents already generated, in the same “project version”
# format, separated by packaged & cloned hashes.
base=/var/www/drupal.org/htdocs/files/release-hashes/
find "${base}${project}" -type f | sed -e "s#^${base}##" -e 's#/# #' | tee >(grep '\-packaged\.csig' | sed -e 's#/.*$##' | sort > packaged.txt) | grep -v '\-packaged\.csig' | sed -e 's#/.*$##' | sort > cloned.txt

# Find release which do not have contents generated.
diff -u releases.txt cloned.txt | sed -n -e 's/^-//p' | tail -n +2 > missing-cloned.txt
diff -u releases.txt packaged.txt | sed -n -e 's/^-//p' | tail -n +2 > missing-packaged.txt

# Combine lists of missing releases.
cat missing-cloned.txt missing-packaged.txt | sort | uniq > missing.txt

# Statistics.
wc -l *

# Generate the missing hashes.
xargs --verbose -L 1 --max-procs="${processes}" -I % 'drush -r /var/www/drupal.org/htdocs drupalorg-release-hashes -v %' < missing.txt
