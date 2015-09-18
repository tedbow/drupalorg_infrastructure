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
DELETE og_users_roles_group FROM og_users_roles_group LEFT JOIN node ON node.nid = og_users_roles_group.gid WHERE node.nid IS NULL;
DELETE f FROM field_data_upload AS f LEFT JOIN comment c ON f.entity_id = c.cid WHERE c.cid IS NULL;
DELETE f FROM field_revision_upload AS f LEFT JOIN comment c ON f.entity_id = c.cid WHERE c.cid IS NULL;
