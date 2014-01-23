-- Executed with mysql -f, every query will be executed, regardless of failure.

-- Empty out scratch tables used during drupal7 migration.
TRUNCATE tracker2_node;
TRUNCATE tracker2_user;
TRUNCATE forum2_index;
TRUNCATE comment_alter_taxonomy;
TRUNCATE mv_drupalorg_node_by_term;
TRUNCATE mv_drupalorg_node_by_vocabulary;

-- Empty out often-bulky search indexes
TRUNCATE search_dataset;
TRUNCATE search_index;
TRUNCATE search_node_links;
TRUNCATE search_total;
