-- Reduce the DB size to make development easier.
-- http://drupal.org/node/636340#comment-3193836
DELETE FROM node WHERE type IN ('forum','project_issue') AND created < (unix_timestamp() - 60*24*60*60);
DELETE node, project_issues FROM node INNER JOIN project_issues WHERE node.nid = project_issues.nid AND project_issues.sid IN (7,14,2);
DELETE node FROM node LEFT JOIN comment ON node.nid = comment.nid WHERE node.type = 'forum' AND comment.nid IS NULL;
DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid WHERE node.nid IS NULL;
DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid AND node.vid = node_revision.vid WHERE node.nid IS NULL AND node_revision.timestamp < (unix_timestamp() - 60*24*60*60);
DELETE node_comment_statistics FROM node_comment_statistics LEFT JOIN node ON node.nid = node_comment_statistics.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN node ON node.nid = comment.nid WHERE node.nid IS NULL;

DELETE field_data_body FROM field_data_body LEFT JOIN node_revision ON node_revision.vid = field_data_body.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_body FROM field_revision_body LEFT JOIN node_revision ON node_revision.vid = field_revision_body.revision_id WHERE node_revision.vid IS NULL;
DELETE field_data_comment_body FROM field_data_comment_body LEFT JOIN comment ON comment.cid = field_data_comment_body.entity_id WHERE comment.cid IS NULL;

DELETE FROM versioncontrol_operations WHERE date < (unix_timestamp() - 60*24*60*60);
DELETE versioncontrol_item_revisions FROM versioncontrol_item_revisions LEFT JOIN versioncontrol_operations ON versioncontrol_item_revisions.vc_op_id = versioncontrol_operations.vc_op_id WHERE versioncontrol_operations.vc_op_id IS NULL;
DELETE versioncontrol_git_item_revisions FROM versioncontrol_git_item_revisions LEFT JOIN versioncontrol_item_revisions ON versioncontrol_git_item_revisions.item_revision_id = versioncontrol_item_revisions.item_revision_id WHERE versioncontrol_item_revisions.item_revision_id IS NULL;
