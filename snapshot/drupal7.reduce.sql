-- Sanitize DB for development. Usually would go in drupal7.dev.sql, but we
-- need the space that snapshot would use.
UPDATE users SET access = 280299600;

-- Get rid of irrelevant data.
TRUNCATE blocked_ips;

-- Remove sensitive variables and profile data
DELETE FROM profile_value WHERE fid IN (select fid FROM profile_field WHERE visibility in (1, 4));

-- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
DELETE f FROM field_data_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
DELETE f FROM field_revision_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
DELETE f FROM field_data_comment_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
DELETE f FROM field_revision_comment_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);

DELETE FROM node WHERE status <> 1;
DELETE FROM comment WHERE status <> 1;
DELETE node FROM node LEFT JOIN users ON node.uid = users.uid WHERE users.uid IS NULL;
DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN node ON node.nid = comment.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN users ON comment.uid = users.uid WHERE users.uid IS NULL;
DELETE comment FROM comment LEFT JOIN comment c2 ON comment.pid = c2.cid WHERE c2.cid IS NULL AND comment.pid <> 0;
DELETE project_issue_comments FROM project_issue_comments LEFT JOIN node ON node.nid = project_issue_comments.nid WHERE node.nid IS NULL;
DELETE project_issue_comments FROM project_issue_comments LEFT JOIN comment ON comment.cid = project_issue_comments.cid WHERE comment.cid IS NULL;
DELETE files FROM files LEFT JOIN users ON files.uid = users.uid WHERE users.uid IS NULL;
DELETE image FROM image LEFT JOIN node ON image.nid = node.nid WHERE node.nid IS NULL;

-- Remove assorted IP / email data
UPDATE comment SET hostname = "127.0.0.1";
UPDATE role_activity SET ip = "127.0.0.1";
UPDATE sshkey SET title = "nobody@nomail.invalid";

-- Tables that should be removed.
DROP TABLE tracker2_node; -- Not used in D7.
DROP TABLE tracker2_user;
DROP TABLE forum2_index;


-- Reduce the DB size to make development easier.
-- http://drupal.org/node/636340#comment-3193836
DELETE FROM node WHERE type IN ('forum','project_issue') AND created < (unix_timestamp() - 60*24*60*60);
DELETE node, project_issues FROM node INNER JOIN project_issues WHERE node.nid = project_issues.nid AND project_issues.sid IN (7,14,2);
DELETE node FROM node LEFT JOIN comment ON node.nid = comment.nid WHERE node.type = 'forum' AND comment.nid IS NULL;
DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid WHERE node.nid IS NULL;
DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid AND node.vid = node_revision.vid WHERE node.nid IS NULL AND node_revision.timestamp < (unix_timestamp() - 60*24*60*60);
DELETE node_comment_statistics FROM node_comment_statistics LEFT JOIN node ON node.nid = node_comment_statistics.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN node ON node.nid = comment.nid WHERE node.nid IS NULL;
DELETE comment_alter_taxonomy FROM comment_alter_taxonomy LEFT JOIN comment ON comment_alter_taxonomy.cid = comment.cid WHERE comment.cid IS NULL;
DELETE project_issues FROM project_issues LEFT JOIN node ON node.nid = project_issues.nid WHERE node.nid IS NULL;
DELETE project_issue_comments FROM project_issue_comments LEFT JOIN node ON node.nid = project_issue_comments.nid WHERE node.nid IS NULL;
DELETE project_issue_comments FROM project_issue_comments LEFT JOIN comment ON comment.cid = project_issue_comments.cid WHERE comment.cid IS NULL;

DELETE field_data_body FROM field_data_body LEFT JOIN node_revision ON node_revision.vid = field_data_body.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_body FROM field_revision_body LEFT JOIN node_revision ON node_revision.vid = field_revision_body.revision_id WHERE node_revision.vid IS NULL;
DELETE field_data_comment_body FROM field_data_comment_body LEFT JOIN comment ON comment.cid = field_data_comment_body.entity_id WHERE comment.cid IS NULL;
DELETE field_data_field_issue_changes FROM field_data_field_issue_changes LEFT JOIN node_revision ON node_revision.vid = field_data_field_issue_changes.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_field_issue_changes FROM field_revision_field_issue_changes LEFT JOIN node_revision ON node_revision.vid = field_revision_field_issue_changes.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_field_issue_files FROM field_revision_field_issue_files LEFT JOIN node_revision ON node_revision.vid = field_revision_field_issue_files.revision_id WHERE node_revision.vid IS NULL;

DELETE FROM versioncontrol_operations WHERE author_date < (unix_timestamp() - 60*24*60*60);
DELETE versioncontrol_item_revisions FROM versioncontrol_item_revisions LEFT JOIN versioncontrol_operations ON versioncontrol_item_revisions.vc_op_id = versioncontrol_operations.vc_op_id WHERE versioncontrol_operations.vc_op_id IS NULL;
DELETE versioncontrol_git_item_revisions FROM versioncontrol_git_item_revisions LEFT JOIN versioncontrol_item_revisions ON versioncontrol_git_item_revisions.item_revision_id = versioncontrol_item_revisions.item_revision_id WHERE versioncontrol_item_revisions.item_revision_id IS NULL;
