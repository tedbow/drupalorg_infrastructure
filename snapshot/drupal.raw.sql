-- Raw is not sanitized.
UPDATE apachesolr_environment SET url = 'http://not.indexed.invalid';

-- Empty out scratch tables used during drupal7 migration.
DROP TABLE project_issue_projects;
DROP TABLE projects;
DROP TABLE project_issues;
DROP TABLE project_issue_comments;
DROP TABLE project_releases_backup;
DROP TABLE project_releases;
DROP TABLE project_release_nodes;
DROP TABLE project_release_legacy;
DROP TABLE project;
DROP TABLE project_release_projects;
DROP TABLE project_comments_conversion_errors;
DROP TABLE project_issue_priority;
DROP TABLE project_issue_state;
DROP TABLE comment_upload;
