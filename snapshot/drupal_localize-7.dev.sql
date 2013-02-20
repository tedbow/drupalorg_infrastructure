-- Sanitize information
UPDATE users_access_old SET access = 280299600;
UPDATE users SET access = 280299600;
TRUNCATE blocked_ips;
UPDATE comment SET mail = CONCAT(name, '@sanitized.invalid'), hostname = "127.0.0.1";

-- Get rid of irrelevant data.
TRUNCATE og_notifications;

-- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
DELETE FROM node WHERE status <> 1;
DELETE FROM comment WHERE status <> 1;
DELETE node FROM node LEFT JOIN users ON node.uid = users.uid WHERE users.uid IS NULL;
DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN node ON node.nid = comment.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN users ON comment.uid = users.uid WHERE users.uid IS NULL;
DELETE comment FROM comment LEFT JOIN comment c2 ON comment.pid = c2.cid WHERE c2.cid IS NULL AND comment.pid <> 0;
DELETE og FROM og LEFT JOIN node ON node.nid = og.etid AND og.entity_type = 'node' WHERE node.nid IS NULL;
DELETE og_membership FROM og_membership LEFT JOIN node ON node.nid = og_membership.gid AND og_membership.group_type = 'node' WHERE node.nid IS NULL;
DELETE og_membership FROM og_membership LEFT JOIN users ON users.uid = og_membership.etid AND og_membership.entity_type = 'user' WHERE users.uid IS NULL;
DELETE og_users_roles FROM og_users_roles LEFT JOIN og ON og.gid = og_users_roles.gid WHERE og.gid IS NULL;
DELETE og_users_roles_group FROM og_users_roles_group LEFT JOIN og ON og.gid = og_users_roles_group.gid WHERE og.gid IS NULL;
DELETE d6_og FROM d6_og LEFT JOIN node ON node.nid = d6_og.nid WHERE node.nid IS NULL;
DELETE d6_og_users_roles FROM d6_og_users_roles LEFT JOIN og ON og.gid = d6_og_users_roles.gid WHERE og.gid IS NULL;

-- Get rid of the most of the l10n_server projects to reduce data size.
DELETE FROM l10n_server_project WHERE weight > -40000;
DELETE l10n_server_release FROM l10n_server_release LEFT JOIN l10n_server_project ON l10n_server_project.pid = l10n_server_release.pid WHERE l10n_server_project.pid IS NULL;
DELETE l10n_server_line FROM l10n_server_line LEFT JOIN l10n_server_project ON l10n_server_project.pid = l10n_server_line.pid WHERE l10n_server_project.pid IS NULL;
DELETE l10n_server_file, files FROM l10n_server_file LEFT JOIN files ON files.fid = l10n_server_file.fid LEFT JOIN l10n_server_project ON l10n_server_project.pid = l10n_server_file.pid WHERE l10n_server_project.pid IS NULL;
DELETE l10n_server_string FROM l10n_server_string LEFT JOIN l10n_server_line ON l10n_server_string.sid = l10n_server_line.sid WHERE l10n_server_line.sid IS NULL;
DELETE l10n_server_status_flag FROM l10n_server_status_flag LEFT JOIN l10n_server_string ON l10n_server_status_flag.sid = l10n_server_string.sid WHERE l10n_server_string.sid IS NULL;
DELETE l10n_server_translation FROM l10n_server_translation LEFT JOIN l10n_server_string ON l10n_server_translation.sid = l10n_server_string.sid WHERE l10n_server_string.sid IS NULL;
DELETE l10n_server_translation_history FROM l10n_server_translation_history LEFT JOIN l10n_server_translation ON l10n_server_translation_history.tid = l10n_server_translation.tid WHERE l10n_server_translation.tid IS NULL;
