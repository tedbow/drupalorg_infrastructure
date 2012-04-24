-- CAUTION: DO NOT RUN THIS ON DATABASE WHERE YOU CARE ABOUT THE INFORMATION!!!

UPDATE users_access SET access = 280299600;
UPDATE cvs_accounts SET pass = '';

-- Get rid of irrelevant data.
TRUNCATE mailhandler;

-- Remove sensitive variables and profile data
DELETE FROM profile_values WHERE fid IN (select fid from profile_fields where visibility in (1, 4));

-- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
DELETE FROM node WHERE status <> 1;
DELETE FROM comments WHERE status <> 0;
DELETE node FROM node LEFT JOIN users ON node.uid = users.uid WHERE users.uid IS NULL;
DELETE node_revisions FROM node_revisions LEFT JOIN node ON node.nid = node_revisions.nid WHERE node.nid IS NULL;
DELETE comments FROM comments LEFT JOIN node ON node.nid = comments.nid WHERE node.nid IS NULL;
DELETE comments FROM comments LEFT JOIN users ON comments.uid = users.uid WHERE users.uid IS NULL;
DELETE comments FROM comments LEFT JOIN comments c2 ON comments.pid = c2.cid WHERE c2.cid IS NULL AND comments.pid <> 0;
DELETE project_issue_comments FROM project_issue_comments LEFT JOIN node ON node.nid = project_issue_comments.nid WHERE node.nid IS NULL;
DELETE project_issue_comments FROM project_issue_comments LEFT JOIN comments ON comments.cid = project_issue_comments.cid WHERE comments.cid IS NULL;
DELETE files FROM files LEFT JOIN users ON files.uid = users.uid WHERE users.uid IS NULL;
DELETE files FROM files INNER JOIN upload ON files.fid = upload.fid LEFT JOIN node ON upload.nid = node.nid WHERE upload.fid IS NULL;
DELETE upload FROM upload LEFT JOIN node ON upload.nid = node.nid WHERE node.nid IS NULL;
DELETE files FROM files INNER JOIN comment_upload ON files.fid = comment_upload.fid LEFT JOIN comments ON comments.cid = comment_upload.cid WHERE comments.cid IS NULL;
DELETE comment_upload FROM comment_upload LEFT JOIN comments ON comments.cid = comment_upload.cid WHERE comments.cid IS NULL;
DELETE image FROM image LEFT JOIN node ON image.nid = node.nid WHERE node.nid IS NULL;
DELETE image_attach FROM image_attach LEFT JOIN node ON image_attach.nid = node.nid WHERE node.nid IS NULL;

DELETE tracker2_node FROM tracker2_node LEFT JOIN node ON node.nid = tracker2_node.nid WHERE node.nid IS NULL;
DELETE tracker2_user FROM tracker2_user LEFT JOIN node ON node.nid = tracker2_user.nid WHERE node.nid IS NULL;
DELETE tracker2_user FROM tracker2_user LEFT JOIN users ON users.uid = tracker2_user.uid WHERE users.uid IS NULL;
DELETE forum2_index FROM forum2_index LEFT JOIN node ON forum2_index.nid = node.nid WHERE node.nid IS NULL;
