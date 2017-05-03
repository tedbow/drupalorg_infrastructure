-- Executed with mysql -f, every query will be executed, regardless of failure.

-- Audit D.o's DB schema and remove legacy tables from before D7 upgrade https://www.drupal.org/node/2443023
DROP TABLE tracker2_node;
DROP TABLE tracker2_user;
DROP TABLE forum2_index;
DROP TABLE comment_alter_taxonomy;
DROP TABLE mv_drupalorg_node_by_term;
DROP TABLE mv_drupalorg_node_by_vocabulary;
DROP TABLE simplenews_newsletters;
DROP TABLE simplenews_snid_tid;
DROP TABLE simplenews_subscriptions;
DROP TABLE content_type_book_listing;
DROP TABLE content_type_casestudy;
DROP TABLE content_type_changenotice;
DROP TABLE content_type_organization;
DROP TABLE content_type_project_project;
DROP TABLE project_releases_backup;
DROP TABLE project_releases;
DROP TABLE project_release_nodes;
DROP TABLE project_release_legacy;
DROP TABLE projects;
DROP TABLE project;
DROP TABLE project_release_projects;
DROP TABLE project_comments_conversion_errors;
DROP TABLE project_issue_comments;
DROP TABLE project_issue_priority;
DROP TABLE project_issue_projects;
DROP TABLE project_issue_state;
DROP TABLE project_issues;
DROP TABLE d6_upgrade_filter;
DROP TABLE field_deleted_data_257;
DROP TABLE field_deleted_data_303;
DROP TABLE field_deleted_revision_257;
DROP TABLE field_deleted_revision_303;

-- Drop legacy CVS integration tables from the DB https://www.drupal.org/node/1302028
DROP TABLE cvs;
DROP TABLE cvs_accounts;
DROP TABLE cvs_cache_block;
DROP TABLE cvs_files;
DROP TABLE cvs_files_attic;
DROP TABLE cvs_messages;
DROP TABLE cvs_messages_attic;
DROP TABLE cvs_migration;
DROP TABLE cvs_project_maintainers;
DROP TABLE cvs_projects;
DROP TABLE cvs_repositories;
DROP TABLE cvs_tags;
DROP TABLE cvs_tags_attic;

-- Empty out often-bulky search indexes
TRUNCATE search_dataset;
TRUNCATE search_index;
TRUNCATE search_node_links;
TRUNCATE search_total;
