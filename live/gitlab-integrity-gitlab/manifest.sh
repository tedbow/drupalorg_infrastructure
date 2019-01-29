# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Users.
sudo gitlab-psql -d gitlabhq_production -c "COPY (SELECT username, id, name, email, state, projects_limit, website_url, replace(coalesce(avatar, ''), 'default-avatar.png', '') FROM users WHERE email LIKE '%.no-reply.drupal.org') TO STDOUT" | sort > users.tsv

# Emails.
sudo gitlab-psql -d gitlabhq_production -c "COPY (SELECT u.username, e.email, e.confirmed_at IS NOT NULL confirmed FROM emails e INNER JOIN users u ON u.id = e.user_id AND u.email LIKE '%.no-reply.drupal.org') TO STDOUT" | sort > emails.tsv

# SSH keys.
sudo gitlab-psql -d gitlabhq_production -c "COPY (SELECT u.username, replace(k.fingerprint, ':', '') fingerprint FROM keys k INNER JOIN users u ON u.id = k.user_id AND u.email LIKE '%.no-reply.drupal.org') TO STDOUT" | sort > keys.tsv

# Projects.
sudo gitlab-psql -d gitlabhq_production -c "COPY (SELECT p.name, p.id, lower(p.path), p.description, p.import_url, n.path, pmd.status FROM projects p LEFT JOIN project_mirror_data pmd ON pmd.project_id = p.id LEFT JOIN namespaces n ON n.id = p.namespace_id) TO STDOUT" | sort > projects.tsv

# Maintainers.
sudo gitlab-psql -d gitlabhq_production -c "COPY (SELECT p.name, u.username, m.access_level FROM members m INNER JOIN users u ON u.id = m.user_id INNER JOIN projects p ON p.id = m.source_id WHERE m.type = 'ProjectMember') TO STDOUT" | sort > maintainers.tsv

# Checksums.
sudo gitlab-psql -d gitlabhq_production -c "COPY (SELECT p.name, lpad(substring(prs.repository_verification_checksum::text, 3), 40, '0') FROM projects p LEFT JOIN project_repository_states prs ON prs.project_id = p.id) TO STDOUT" | sort > checksums.tsv
