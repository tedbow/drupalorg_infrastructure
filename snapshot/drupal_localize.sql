-- CAUTION: DO NOT RUN THIS ON DATABASE WHERE YOU CARE ABOUT THE INFORMATION!!!

-- Munge emails for security.
UPDATE users SET mail = CONCAT(name, '@localhost'), init = CONCAT('http://drupal.org/user/', uid, '/edit'), pass = MD5(CONCAT('drupal', name)), data = '';
UPDATE comments SET mail = CONCAT(name, '@localhost');
UPDATE authmap SET authname = CONCAT(aid, '@localhost');
UPDATE users_access SET access = 280299600;


-- Get rid of irrelevant data.
TRUNCATE batch;
TRUNCATE semaphore;
TRUNCATE access;
TRUNCATE og_notifications;

-- Remove sensitive variables and profile data
DELETE FROM variable WHERE name = 'drupal_private_key';
DELETE FROM variable WHERE name LIKE '%key%';

-- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
DELETE FROM node WHERE status <> 1;
DELETE FROM comments WHERE status <> 0;
DELETE FROM users WHERE status <> 1 AND uid <> 0;
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
