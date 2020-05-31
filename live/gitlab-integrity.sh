# Exit immediately on uninitialized variable or error, and print each command.
set -uex

mkdir -p www
mkdir -p gitlab

# Start GitLab in the background.
ssh gitlab1.drupal.bak /usr/local/drupal-infrastructure/live/gitlab-integrity-gitlab/manifest.sh &

# Users.
echo "SELECT u.git_username, vgu.gitlab_user_id, u.name, concat(lower(u.git_username), '@', u.uid, '.no-reply.drupal.org') mail, if(u.status AND ur.rid IS NOT NULL, 'active', 'blocked') status, 0, concat('https://www.drupal.org/', coalesce(ua.alias, concat('user/', u.uid))) website, coalesce(substring_index(fm.uri, '/', -1), '') avatar FROM users u INNER JOIN versioncontrol_gitlab_users vgu ON vgu.uid = u.uid LEFT JOIN users_roles ur ON ur.uid = u.uid AND ur.rid = 20 LEFT JOIN url_alias ua ON ua.source = concat('user/', u.uid) LEFT JOIN file_managed fm ON fm.fid = u.picture" | drush -r /var/www/drupal.org/htdocs sql-cli --extra='--skip-column-names' | sort > www/users.tsv

# Emails.
echo "SELECT u.git_username, lower(me.email), if(me.confirmed, 't', 'f') confirmed FROM multiple_email me INNER JOIN users u ON u.uid = me.uid AND git_username IS NOT NULL INNER JOIN versioncontrol_gitlab_users vgu ON vgu.uid = u.uid WHERE me.confirmed" | drush -r /var/www/drupal.org/htdocs sql-cli --extra='--skip-column-names' | sort > www/emails.tsv

# SSH keys.
echo "SELECT u.git_username, s.fingerprint FROM sshkey s INNER JOIN users u ON u.uid = s.entity_id AND git_consent = 1 AND git_username IS NOT NULL WHERE s.entity_type = 'user'" | drush -r /var/www/drupal.org/htdocs sql-cli --extra='--skip-column-names' | sort > www/keys.tsv

# Projects.
echo "SELECT vr.name repository, vgr.gitlab_project_id, lower(vr.name) name, concat('For more information about this repository, visit the project page at https://www.drupal.org/', ua.alias) description, if(fdf_pt.field_project_type_value = 'sandbox', 'sandbox', 'project') namespace, 'f' request_access_enabled, 't' active, 'Drupal.org project' title FROM versioncontrol_repositories vr INNER JOIN versioncontrol_project_projects vpp ON vpp.repo_id = vr.repo_id INNER JOIN field_data_field_project_type fdf_pt ON fdf_pt.entity_id = vpp.nid INNER JOIN node n ON n.nid = vpp.nid LEFT JOIN versioncontrol_gitlab_repositories vgr ON vgr.repo_id = vr.repo_id LEFT JOIN url_alias ua ON ua.source = concat('node/', n.nid)" | drush -r /var/www/drupal.org/htdocs sql-cli --extra='--skip-column-names' | sort > www/projects.tsv

# Maintainers.
echo "SELECT vr.name repository, u.git_username, 30 FROM versioncontrol_auth_account vaa INNER JOIN users u ON u.uid = vaa.uid AND git_consent = 1 AND git_username IS NOT NULL INNER JOIN versioncontrol_repositories vr ON vr.repo_id = vaa.repo_id INNER JOIN versioncontrol_project_projects vpp ON vpp.repo_id = vr.repo_id INNER JOIN field_data_field_project_type fdf_pt ON fdf_pt.entity_id = vpp.nid INNER JOIN node n ON n.nid = vpp.nid WHERE vaa.access != 0" | drush -r /var/www/drupal.org/htdocs sql-cli --extra='--skip-column-names' | sort > www/maintainers.tsv

# Get results from GitLab.
wait
scp gitlab1.drupal.bak:{users,emails,keys,projects,maintainers}.tsv gitlab/

code=0

for f in {users,emails,keys,projects,maintainers}; do
  diff -u "www/${f}.tsv" "gitlab/${f}.tsv" | grep '^[+-]' > "${f}.diff" && code=1 || true
done

# Alert if any are non-empty.
exit "${code}"
