"""@skeleton docstring
The skeleton dataset is the lightest weight of all images.

  * fully sanitized
  * heavily trimmed

It is suitable for work on:

  * the unbranded D.o theme
  * case studies
  * issue queue

It is NOT suitable for work on:

  * D.o brand elements
  * commit logs
  * git
  * packaging
  * solr
"""

# TODO: The following SQL is currently used for the Drupal.org-hosted Dev environments


# http://drupalcode.org/project/infrastructure.git/blob/HEAD:/snapshot/common.dev.sql

  DELETE FROM users WHERE status <> 1 AND uid <> 0 AND name <> 'bacon'; #delete blocked users
  DELETE users_roles FROM users_roles LEFT JOIN users ON users_roles.uid = users.uid WHERE users.uid IS NULL; #remove user roles for deleted users


# http://drupalcode.org/project/infrastructure.git/blob/HEAD:/snapshot/drupal.dev.sql

  UPDATE users_access SET access = 280299600; #obfuscate last access
  UPDATE users SET access = 280299600; #obfuscate last access
  TRUNCATE blocked_ips; #don't show blocked IPs

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

# http://drupalcode.org/project/infrastructure.git/blob/HEAD:/snapshot/drupal.reduce.sql

  -- CAUTION: DO NOT RUN THIS ON DATABASE WHERE YOU CARE ABOUT THE INFORMATION!!!

  -- Reduce the DB size to make development easier.
  -- http://drupal.org/node/636340#comment-3193836
  DELETE FROM node WHERE type IN ('forum','project_issue') AND created < (unix_timestamp() - 60*24*60*60);
  DELETE node FROM node LEFT JOIN comment ON node.nid = comment.nid WHERE node.type = 'forum' AND comment.nid IS NULL;
  DELETE tracker_user FROM tracker_user LEFT JOIN node ON tracker_user.nid = node.nid WHERE node.nid IS NULL;
  DELETE tracker_user FROM tracker_user LEFT JOIN users ON tracker_user.uid = users.uid WHERE users.uid IS NULL;
  DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid WHERE node.nid IS NULL;
  DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid AND node.vid = node_revision.vid WHERE node.nid IS NULL AND node_revision.timestamp < (unix_timestamp() - 60*24*60*60);
  DELETE node_comment_statistics FROM node_comment_statistics LEFT JOIN node ON node.nid = node_comment_statistics.nid WHERE node.nid IS NULL;
  DELETE comment FROM comment LEFT JOIN node ON node.nid = comment.nid WHERE node.nid IS NULL;

  DELETE field_data_body FROM field_data_body LEFT JOIN node_revision ON node_revision.vid = field_data_body.revision_id WHERE node_revision.vid IS NULL;
  DELETE field_revision_body FROM field_revision_body LEFT JOIN node_revision ON node_revision.vid = field_revision_body.revision_id WHERE node_revision.vid IS NULL;
  DELETE field_data_comment_body FROM field_data_comment_body LEFT JOIN comment ON comment.cid = field_data_comment_body.entity_id WHERE comment.cid IS NULL;
  DELETE field_data_field_issue_changes FROM field_data_field_issue_changes LEFT JOIN comment ON comment.cid = field_data_field_issue_changes.entity_id WHERE comment.cid IS NULL;
  DELETE field_revision_field_issue_changes FROM field_revision_field_issue_changes LEFT JOIN field_data_field_issue_changes ON field_data_field_issue_changes.entity_id = field_revision_field_issue_changes.entity_id WHERE field_data_field_issue_changes.entity_id IS NULL;
  DELETE field_revision_field_issue_files FROM field_revision_field_issue_files LEFT JOIN node_revision ON node_revision.vid = field_revision_field_issue_files.revision_id WHERE node_revision.vid IS NULL;

  DELETE FROM versioncontrol_operations WHERE author_date < (unix_timestamp() - 60*24*60*60);
  DELETE versioncontrol_item_revisions FROM versioncontrol_item_revisions LEFT JOIN versioncontrol_operations ON versioncontrol_item_revisions.vc_op_id = versioncontrol_operations.vc_op_id WHERE versioncontrol_operations.vc_op_id IS NULL;
  DELETE versioncontrol_git_item_revisions FROM versioncontrol_git_item_revisions LEFT JOIN versioncontrol_item_revisions ON versioncontrol_git_item_revisions.item_revision_id = versioncontrol_item_revisions.item_revision_id WHERE versioncontrol_item_revisions.item_revision_id IS NULL;
  DELETE v FROM search_api_db_project_issues_comments_comment_body_value v LEFT JOIN node n ON n.nid = v.item_id WHERE n.nid IS NULL;
  DELETE v FROM search_api_db_project_issues_body_value v LEFT JOIN node n ON n.nid = v.item_id WHERE n.nid IS NULL;
  DELETE v FROM search_api_db_project_issues v LEFT JOIN node n ON n.nid = v.item_id WHERE n.nid IS NULL;
