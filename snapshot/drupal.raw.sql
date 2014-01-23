-- Raw is not sanitized.
UPDATE apachesolr_environment SET url = 'http://not.indexed.invalid';

-- Empty out scratch tables used during drupal7 migration.
TRUNCATE project_issue_projects;
TRUNCATE projects;
TRUNCATE project_issues;
TRUNCATE project_issue_comments;
TRUNCATE comment_upload;
