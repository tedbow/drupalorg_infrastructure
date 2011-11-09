-- CAUTION: DO NOT RUN THIS ON DATABASE WHERE YOU CARE ABOUT THE INFORMATION!!!

-- Munge emails for security.
UPDATE users SET mail = CONCAT(name, '@localhost'), init = CONCAT('http://drupal.org/user/', uid, '/edit'), pass = MD5(CONCAT('drupal', name));
UPDATE comments SET mail = CONCAT(name, '@localhost');
UPDATE authmap SET authname = CONCAT(aid, '@localhost');
UPDATE users SET access = 280299600;

-- Get rid of irrelevant data.
TRUNCATE devel_queries;
TRUNCATE devel_times;
TRUNCATE search_dataset;
TRUNCATE search_index;
TRUNCATE search_node_links;
TRUNCATE search_total;
TRUNCATE access;

-- Remove sensitive variables and profile data
DELETE FROM variable WHERE name = 'drupal_private_key';
DELETE FROM variable WHERE name LIKE '%key%';
DELETE FROM variable WHERE name = 'regonline_account_password';
-- 1 is private, 4 is hidden
DELETE FROM profile_values WHERE fid IN (select fid from profile_fields where visibility in (1, 4));

-- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
DELETE FROM node WHERE status <> 1;
DELETE FROM comments WHERE status <> 0;
DELETE FROM users WHERE status <> 1 AND uid <> 0;
DELETE node FROM node LEFT JOIN users ON node.uid = users.uid WHERE users.uid IS NULL;
DELETE node_revisions FROM node_revisions LEFT JOIN node ON node.nid = node_revisions.nid WHERE node.nid IS NULL;
DELETE comments FROM comments LEFT JOIN node ON node.nid = comments.nid WHERE node.nid IS NULL;
DELETE comments FROM comments LEFT JOIN users ON comments.uid = users.uid WHERE users.uid IS NULL;
DELETE comments FROM comments LEFT JOIN comments c2 ON comments.pid = c2.cid WHERE c2.cid IS NULL AND comments.pid <> 0;
DELETE comments FROM comments LEFT JOIN comments c2 ON comments.pid = c2.cid WHERE c2.cid IS NULL AND comments.pid <> 0;
DELETE comments FROM comments LEFT JOIN comments c2 ON comments.pid = c2.cid WHERE c2.cid IS NULL AND comments.pid <> 0;
DELETE comments FROM comments LEFT JOIN comments c2 ON comments.pid = c2.cid WHERE c2.cid IS NULL AND comments.pid <> 0;
DELETE files FROM files LEFT JOIN users ON files.uid = users.uid WHERE users.uid IS NULL;
DELETE users_roles FROM users_roles LEFT JOIN users ON users_roles.uid = users.uid WHERE users.uid IS NULL;

