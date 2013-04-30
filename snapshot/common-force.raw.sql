-- Executed with mysql -f, every query will be executed, regardless of failure.

-- Empty out scratch tables used during drupal7 migration.
TRUNCATE project_issue_migration_timeline;
TRUNCATE project_issue_migration_timeline_init;
TRUNCATE project_issue_migration_original_thread;
TRUNCATE project_issue_migration_original_issue_data;

-- Empty out often-bulky search indexes
TRUNCATE search_dataset;
TRUNCATE search_index;
TRUNCATE search_node_links;
TRUNCATE search_total;
