-- Dev sanitization.
UPDATE users_access SET access = 280299600;
UPDATE users SET access = 280299600;
TRUNCATE blocked_ips;

-- Remove assorted IP / email data
UPDATE comment SET hostname = "127.0.0.1";
UPDATE role_activity SET ip = "127.0.0.1";
UPDATE sshkey SET title = "nobody@nomail.invalid";

-- Remove sensitive variables and profile data
DELETE FROM profile_value WHERE fid IN (select fid FROM profile_field WHERE visibility in (1, 4));

-- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
DELETE f FROM field_data_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
DELETE f FROM field_revision_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
DELETE f FROM field_data_comment_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
DELETE f FROM field_revision_comment_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);

-- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
DELETE FROM node WHERE status <> 1;
DELETE FROM comment WHERE status <> 1;
DELETE node FROM node LEFT JOIN users ON node.uid = users.uid WHERE users.uid IS NULL;
DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN node ON node.nid = comment.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN users ON comment.uid = users.uid WHERE users.uid IS NULL;
DELETE comment FROM comment LEFT JOIN comment c2 ON comment.pid = c2.cid WHERE c2.cid IS NULL AND comment.pid <> 0;
DELETE files FROM files LEFT JOIN users ON files.uid = users.uid WHERE users.uid IS NULL;
DELETE file_managed FROM file_managed LEFT JOIN users ON file_managed.uid = users.uid WHERE users.uid IS NULL;
DELETE image FROM image LEFT JOIN node ON image.nid = node.nid WHERE node.nid IS NULL;


-- REDUCE the DB size to make development easier.
-- http://drupal.org/node/636340#comment-3193836
DELETE FROM node WHERE type IN ('forum','project_issue') AND created < (unix_timestamp() - 60*24*60*60);
DELETE node FROM node LEFT JOIN comment ON node.nid = comment.nid WHERE node.type = 'forum' AND comment.nid IS NULL;
DELETE tracker_user FROM tracker_user LEFT JOIN node ON tracker_user.nid = node.nid WHERE node.nid IS NULL;
DELETE tracker_user FROM tracker_user LEFT JOIN users ON tracker_user.uid = users.uid WHERE users.uid IS NULL;
DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid WHERE node.nid IS NULL;
DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid AND node.vid = node_revision.vid WHERE node.nid IS NULL AND node_revision.timestamp < (unix_timestamp() - 60*24*60*60);
DELETE node_comment_statistics FROM node_comment_statistics LEFT JOIN node ON node.nid = node_comment_statistics.nid WHERE node.nid IS NULL;

DELETE field_data_body FROM field_data_body LEFT JOIN node_revision ON node_revision.vid = field_data_body.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_body FROM field_revision_body LEFT JOIN node_revision ON node_revision.vid = field_revision_body.revision_id WHERE node_revision.vid IS NULL;
-- Delete comments attached to deleted nodes.
DELETE comment FROM comment LEFT JOIN node ON node.nid = comment.nid WHERE node.nid IS NULL;
DELETE field_data_comment_body FROM field_data_comment_body LEFT JOIN comment ON comment.cid = field_data_comment_body.entity_id WHERE comment.cid IS NULL;
DELETE cb FROM field_revision_comment_body cb LEFT JOIN comment c on c.cid = cb.entity_id WHERE c.cid IS NULL;

DELETE field_data_field_issue_changes FROM field_data_field_issue_changes LEFT JOIN comment ON comment.cid = field_data_field_issue_changes.entity_id WHERE comment.cid IS NULL;
DELETE fdf FROM field_data_field_issue_assigned fdf LEFT JOIN node_revision ON node_revision.vid = fdf.revision_id WHERE node_revision.vid IS NULL;
DELETE fdf FROM field_data_field_issue_category fdf LEFT JOIN node_revision ON node_revision.vid = fdf.revision_id WHERE node_revision.vid IS NULL;
DELETE fdf FROM field_data_field_issue_component fdf LEFT JOIN node_revision ON node_revision.vid = fdf.revision_id WHERE node_revision.vid IS NULL;
DELETE fdf FROM field_data_field_issue_priority fdf LEFT JOIN node_revision ON node_revision.vid = fdf.revision_id WHERE node_revision.vid IS NULL;
DELETE fdf FROM field_data_field_issue_files fdf LEFT JOIN node_revision ON node_revision.vid = fdf.revision_id WHERE node_revision.vid IS NULL;
DELETE fdf FROM field_data_field_issue_status fdf LEFT JOIN node_revision ON node_revision.vid = fdf.revision_id WHERE node_revision.vid IS NULL;
DELETE fdf FROM field_data_field_issue_version fdf LEFT JOIN node_revision ON node_revision.vid = fdf.revision_id WHERE node_revision.vid IS NULL;
DELETE fdf FROM field_data_field_project fdf LEFT JOIN node_revision ON node_revision.vid = fdf.revision_id WHERE node_revision.vid IS NULL;

DELETE field_revision_field_issue_changes FROM field_revision_field_issue_changes LEFT JOIN field_data_field_issue_changes ON field_data_field_issue_changes.entity_id = field_revision_field_issue_changes.entity_id WHERE field_data_field_issue_changes.entity_id IS NULL;
DELETE field_revision_field_issue_files FROM field_revision_field_issue_files LEFT JOIN node_revision ON node_revision.vid = field_revision_field_issue_files.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_field_issue_component FROM field_revision_field_issue_component LEFT JOIN node_revision ON node_revision.vid = field_revision_field_issue_component.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_field_issue_assigned FROM field_revision_field_issue_assigned LEFT JOIN node_revision ON node_revision.vid = field_revision_field_issue_assigned.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_field_issue_category FROM field_revision_field_issue_category LEFT JOIN node_revision ON node_revision.vid = field_revision_field_issue_category.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_field_issue_component FROM field_revision_field_issue_component LEFT JOIN node_revision ON node_revision.vid = field_revision_field_issue_component.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_field_issue_priority FROM field_revision_field_issue_priority LEFT JOIN node_revision ON node_revision.vid = field_revision_field_issue_priority.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_field_issue_related FROM field_revision_field_issue_related LEFT JOIN node_revision ON node_revision.vid = field_revision_field_issue_related.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_field_issue_status FROM field_revision_field_issue_status LEFT JOIN node_revision ON node_revision.vid = field_revision_field_issue_status.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_field_issue_version FROM field_revision_field_issue_version LEFT JOIN node_revision ON node_revision.vid = field_revision_field_issue_version.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_field_project FROM field_revision_field_project LEFT JOIN node_revision ON node_revision.vid = field_revision_field_project.revision_id WHERE node_revision.vid IS NULL;
DELETE field_revision_body FROM field_revision_body LEFT JOIN node_revision ON node_revision.vid = field_revision_body.revision_id WHERE node_revision.vid IS NULL;

-- Delete taxonomy vocab associated with deleted nodes
DELETE ft FROM field_revision_taxonomy_vocabulary_9 ft LEFT JOIN node n on n.nid = ft.entity_id WHERE n.nid is NULL;
-- Delete versioncontrol operations more than 60 days old.
DELETE FROM versioncontrol_operations WHERE author_date < (unix_timestamp() - 60*24*60*60);
DELETE versioncontrol_operation_labels FROM versioncontrol_operation_labels LEFT JOIN versioncontrol_operations ON versioncontrol_operation_labels.vc_op_id = versioncontrol_operations.vc_op_id WHERE versioncontrol_operations.vc_op_id IS NULL;
DELETE versioncontrol_git_operations FROM versioncontrol_git_operations LEFT JOIN versioncontrol_operations ON versioncontrol_git_operations.vc_op_id = versioncontrol_operations.vc_op_id WHERE versioncontrol_operations.vc_op_id IS NULL;
DELETE versioncontrol_item_revisions FROM versioncontrol_item_revisions LEFT JOIN versioncontrol_operations ON versioncontrol_item_revisions.vc_op_id = versioncontrol_operations.vc_op_id WHERE versioncontrol_operations.vc_op_id IS NULL;
DELETE versioncontrol_git_item_revisions FROM versioncontrol_git_item_revisions LEFT JOIN versioncontrol_item_revisions ON versioncontrol_git_item_revisions.item_revision_id = versioncontrol_item_revisions.item_revision_id WHERE versioncontrol_item_revisions.item_revision_id IS NULL;

-- Delete searchapi data that points to deleted nodes.
DELETE v FROM search_api_db_project_issues_project_issue_followers v LEFT JOIN node n on n.nid = v.item_id WHERE n.nid IS NULL;
DELETE v FROM search_api_db_project_issues_project_issue_participants v LEFT JOIN node n on n.nid = v.item_id WHERE n.nid IS NULL;
DELETE v FROM search_api_db_project_issues_text v LEFT JOIN node n ON n.nid = v.item_id WHERE n.nid IS NULL;
DELETE v FROM search_api_db_project_issues v LEFT JOIN node n ON n.nid = v.item_id WHERE n.nid IS NULL;

-- Delete irrelevant sampler data.
DELETE FROM sampler_project_issue_opened_vs_closed_by_category WHERE timestamp < (unix_timestamp() - 2*365*24*60*60);
DELETE FROM sampler_project_issue_reporters_participants_by_project WHERE timestamp < (unix_timestamp() - 2*365*24*60*60);
DELETE FROM sampler_project_issue_responses_by_project WHERE timestamp < (unix_timestamp() - 2*365*24*60*60);
DELETE FROM sampler_project_issue_new_issues_comments_by_project WHERE timestamp < (unix_timestamp() - 2*365*24*60*60);
DELETE FROM sampler_project_release_new_releases WHERE timestamp < (unix_timestamp() - 2*365*24*60*60);

-- Delete flags that point to non-existant nodes.
DELETE fc FROM flag_content fc
LEFT JOIN node n on n.nid = fc.content_id and fc.content_type = 'node'
WHERE n.nid IS NULL;

-- Delete users who have never logged in, and do not author a node.
DELETE u FROM users u LEFT JOIN node n ON n.uid = u.uid WHERE u.login = 0 AND u.uid != 0 AND n.uid IS NULL;
DELETE me FROM multiple_email me LEFT JOIN users u ON u.uid = me.uid WHERE u.uid IS NULL;
DELETE fc FROM field_revision_field_country fc LEFT JOIN users u ON u.uid = fc.entity_id WHERE u.uid IS NULL;
DELETE fc FROM field_data_field_country fc LEFT JOIN users u ON u.uid = fc.entity_id WHERE u.uid IS NULL;

-- Delete role activty > 60 days
DELETE ra FROM role_activity ra WHERE ra.timestamp < (unix_timestamp() - 60*24*60*60);
TRUNCATE TABLE cvs_files;
-- project_usage_week_release
-- project_usage_week_project
