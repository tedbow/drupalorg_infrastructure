UPDATE users SET access = 280299600;

-- Get rid of irrelevant data.
TRUNCATE mailhandler;
TRUNCATE blocked_ips;

-- Remove sensitive variables and profile data
DELETE FROM profile_value WHERE fid IN (select fid FROM profile_field WHERE visibility in (1, 4));

-- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
DELETE f FROM field_data_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
DELETE f FROM field_revision_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
DELETE f FROM field_data_comment_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
DELETE f FROM field_revision_comment_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);

DELETE FROM node WHERE status <> 1;
DELETE FROM comment WHERE status <> 0;
DELETE node FROM node LEFT JOIN users ON node.uid = users.uid WHERE users.uid IS NULL;
DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN node ON node.nid = comment.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN users ON comment.uid = users.uid WHERE users.uid IS NULL;
DELETE comment FROM comment LEFT JOIN comment c2 ON comment.pid = c2.cid WHERE c2.cid IS NULL AND comment.pid <> 0;
DELETE project_issue_comments FROM project_issue_comments LEFT JOIN node ON node.nid = project_issue_comments.nid WHERE node.nid IS NULL;
DELETE project_issue_comments FROM project_issue_comments LEFT JOIN comment ON comment.cid = project_issue_comments.cid WHERE comment.cid IS NULL;
DELETE files FROM files LEFT JOIN users ON files.uid = users.uid WHERE users.uid IS NULL;
DELETE image FROM image LEFT JOIN node ON image.nid = node.nid WHERE node.nid IS NULL;
DELETE image_attach FROM image_attach LEFT JOIN node ON image_attach.nid = node.nid WHERE node.nid IS NULL;

-- Remove assorted IP / email data
UPDATE comment SET hostname = "127.0.0.1";
UPDATE role_activity SET ip = "127.0.0.1";
UPDATE sshkey SET title = "nobody@nomail.invalid";

-- Tables that should be removed.
DROP TABLE tracker2_node; -- Not used in D7.
DROP TABLE tracker2_user;
DROP TABLE forum2_index;
DROP TABLE cvs_accounts; -- http://drupal.org/node/1543548
