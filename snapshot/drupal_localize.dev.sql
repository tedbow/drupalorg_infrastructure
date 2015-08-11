UPDATE users SET access = 280299600;

-- Get rid of irrelevant data.
TRUNCATE og_notifications;

-- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
DELETE FROM node WHERE status <> 1;
DELETE FROM comment WHERE status <> 0;
DELETE node FROM node LEFT JOIN users ON node.uid = users.uid WHERE users.uid IS NULL;
DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN node ON node.nid = comment.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN users ON comment.uid = users.uid WHERE users.uid IS NULL;
DELETE comment FROM comment LEFT JOIN comment c2 ON comment.pid = c2.cid WHERE c2.cid IS NULL AND comment.pid <> 0;
DELETE files FROM files LEFT JOIN users ON files.uid = users.uid WHERE users.uid IS NULL;
DELETE files FROM files INNER JOIN field_data_upload upload ON files.fid = upload.upload_fid LEFT JOIN node ON upload.entity_id = node.nid WHERE upload.upload_fid IS NULL;
DELETE upload FROM field_data_upload upload LEFT JOIN node ON upload.entity_id = node.nid WHERE node.nid IS NULL;
DELETE file_managed FROM file_managed LEFT JOIN users ON file_managed.uid = users.uid WHERE users.uid IS NULL;
DELETE og FROM og LEFT JOIN node ON node.nid = og.nid WHERE node.nid IS NULL;
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
