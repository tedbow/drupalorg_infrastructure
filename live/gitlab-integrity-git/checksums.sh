echo "SELECT vr.root, if(fdf_pt.field_project_type_value = 'sandbox', concat(substring_index(substring_index(vr.root, '/', -2), '/', 1), '-', n.nid), vr.name) repository FROM versioncontrol_repositories vr INNER JOIN versioncontrol_project_projects vpp ON vpp.repo_id = vr.repo_id INNER JOIN field_data_field_project_type fdf_pt ON fdf_pt.entity_id = vpp.nid INNER JOIN node n ON n.nid = vpp.nid LEFT JOIN versioncontrol_gitlab_repositories vgr ON vgr.repo_id = vr.repo_id LEFT JOIN url_alias ua ON ua.source = concat('node/', n.nid) LEFT JOIN versioncontrol_git_repositories vgitr ON vgitr.repo_id = vr.repo_id" | drush -r /var/www/drupal.org/htdocs sql-cli --extra=--skip-column-names | xargs -n 1 -P 10 -I '{}' sh -c "git --git-dir \"\$(echo '{}' | sed -e 's/\t.*//')\" show-ref --head | php /usr/local/drupal-infrastructure/live/gitlab-integrity-git/checksum.php \$(echo '{}' | sed -e 's/.*\t//')" | sort
