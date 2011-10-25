-- CAUTION: DO NOT RUN THIS ON DATABASE WHERE YOU CARE ABOUT THE INFORMATION!!!

-- Reduce the DB size to make development easier.
-- http://drupal.org/node/636340#comment-3193836
DELETE FROM node WHERE type IN ('forum','project_issue') AND created < (unix_timestamp() - 80*24*60*60);
DELETE node, project_issues FROM node INNER JOIN project_issues WHERE node.nid = project_issues.nid AND project_issues.sid IN (7,14,2);
DELETE node FROM node LEFT JOIN comments ON node.nid = comments.nid WHERE node.type = 'forum' AND comments.nid IS NULL;
DELETE node_revisions FROM node_revisions LEFT JOIN node ON node.nid = node_revisions.nid WHERE node.nid IS NULL;
DELETE node_revisions FROM node_revisions LEFT JOIN node ON node.nid = node_revisions.nid AND node.vid = node_revisions.vid WHERE node.nid IS NULL AND node_revisions.timestamp < (unix_timestamp() - 80*24*60*60);
DELETE node_comment_statistics FROM node_comment_statistics LEFT JOIN node ON node.nid = node_comment_statistics.nid WHERE node.nid IS NULL;
TRUNCATE node_counter;
DELETE comments FROM comments LEFT JOIN node ON node.nid = comments.nid WHERE node.nid IS NULL;
DELETE tracker2_user FROM tracker2_user LEFT JOIN node ON tracker2_user.nid = node.nid WHERE node.nid IS NULL;
DELETE forum2_index FROM forum2_index LEFT JOIN node ON forum2_index.nid = node.nid WHERE node.nid IS NULL;
