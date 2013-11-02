-- Executed with mysql -f, every query will be executed, regardless of failure.

-- Empty out scratch tables used during drupal7 migration.
TRUNCATE project_issue_migration_timeline;
TRUNCATE project_issue_migration_timeline_init;
TRUNCATE project_issue_migration_original_thread;
TRUNCATE project_issue_migration_original_issue_data;
TRUNCATE search_index_d6;
TRUNCATE search_total_d6;
TRUNCATE project_issue_projects;
TRUNCATE projects;
TRUNCATE project_issues;
TRUNCATE project_issue_comments;
TRUNCATE comment_upload;
TRUNCATE tracker2_node;
TRUNCATE tracker2_user;
TRUNCATE forum2_index;
TRUNCATE comment_alter_taxonomy;

-- Empty out often-bulky search indexes
TRUNCATE search_dataset;
TRUNCATE search_index;
TRUNCATE search_node_links;
TRUNCATE search_total;
