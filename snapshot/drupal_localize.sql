UPDATE users_access SET access = 280299600;

-- Get rid of irrelevant data.
TRUNCATE og_notifications;

-- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
DELETE FROM node WHERE status <> 1;
DELETE FROM comments WHERE status <> 0;
DELETE node FROM node LEFT JOIN users ON node.uid = users.uid WHERE users.uid IS NULL;
DELETE node_revisions FROM node_revisions LEFT JOIN node ON node.nid = node_revisions.nid WHERE node.nid IS NULL;
DELETE comments FROM comments LEFT JOIN node ON node.nid = comments.nid WHERE node.nid IS NULL;
DELETE comments FROM comments LEFT JOIN users ON comments.uid = users.uid WHERE users.uid IS NULL;
DELETE comments FROM comments LEFT JOIN comments c2 ON comments.pid = c2.cid WHERE c2.cid IS NULL AND comments.pid <> 0;
DELETE files FROM files LEFT JOIN users ON files.uid = users.uid WHERE users.uid IS NULL;
DELETE files FROM files INNER JOIN upload ON files.fid = upload.fid LEFT JOIN node ON upload.nid = node.nid WHERE upload.fid IS NULL;
DELETE upload FROM upload LEFT JOIN node ON upload.nid = node.nid WHERE node.nid IS NULL;
DELETE users_roles FROM users_roles LEFT JOIN users ON users_roles.uid = users.uid WHERE users.uid IS NULL;
DELETE og FROM og LEFT JOIN node ON node.nid = og.nid WHERE node.nid IS NULL;
DELETE og_ancestry FROM og_ancestry LEFT JOIN node ON node.nid = og_ancestry.nid WHERE node.nid IS NULL;
DELETE og_ancestry FROM og_ancestry LEFT JOIN node ON node.nid = og_ancestry.group_nid WHERE node.nid IS NULL;
DELETE og_uid FROM og_uid LEFT JOIN node ON node.nid = og_uid.nid WHERE node.nid IS NULL;
DELETE og_uid FROM og_uid LEFT JOIN users ON og_uid.uid = users.uid WHERE users.uid IS NULL;
DELETE og_users_roles_group FROM og_users_roles_group LEFT JOIN node ON node.nid = og_users_roles_group.gid WHERE node.nid IS NULL;

-- Get rid of the most of the l10n_server projects to reduce data size.
DELETE FROM l10n_server_project WHERE weight > -40000;
DELETE l10n_server_release FROM l10n_server_release LEFT JOIN l10n_server_project ON l10n_server_project.pid = l10n_server_release.pid WHERE l10n_server_project.pid IS NULL;
DELETE l10n_server_line FROM l10n_server_line LEFT JOIN l10n_server_project ON l10n_server_project.pid = l10n_server_line.pid WHERE l10n_server_project.pid IS NULL;
DELETE l10n_server_file FROM l10n_server_file LEFT JOIN l10n_server_project ON l10n_server_project.pid = l10n_server_file.pid WHERE l10n_server_project.pid IS NULL;
DELETE l10n_server_string FROM l10n_server_string LEFT JOIN l10n_server_line ON l10n_server_string.sid = l10n_server_line.sid WHERE l10n_server_line.sid IS NULL;
DELETE l10n_server_status_flag FROM l10n_server_status_flag LEFT JOIN l10n_server_string ON l10n_server_status_flag.sid = l10n_server_string.sid WHERE l10n_server_string.sid IS NULL;
DELETE l10n_server_translation FROM l10n_server_translation LEFT JOIN l10n_server_string ON l10n_server_translation.sid = l10n_server_string.sid WHERE l10n_server_string.sid IS NULL;
DELETE l10n_server_translation_history FROM l10n_server_translation_history LEFT JOIN l10n_server_translation ON l10n_server_translation_history.tid = l10n_server_translation.tid WHERE l10n_server_translation.tid IS NULL;
