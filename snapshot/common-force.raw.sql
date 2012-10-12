-- Empty out scratch tables used during drupal7 migration.
-- Errors are harmless in other situations.
TRUNCATE project_issue_migration_timeline;
TRUNCATE project_issue_migration_original_thread;
TRUNCATE project_issue_migration_original_issue_data;
