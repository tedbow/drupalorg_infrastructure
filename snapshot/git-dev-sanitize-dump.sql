-- CAUTION: DO NOT RUN THIS ON DATABASE WHERE YOU CARE ABOUT THE INFORMATION!!!

-- Retain emails, but munge passwords for security.
UPDATE users SET init = CONCAT('http://drupal.org/user/', uid, '/edit'), pass = '';
UPDATE comments SET mail = CONCAT(name, '@localhost');
UPDATE directory SET mail = CONCAT(name, '@localhost');
UPDATE authmap SET authname = CONCAT(aid, '@localhost');
UPDATE client SET mail = CONCAT(cid, '@localhost');
UPDATE donations SET mail = CONCAT(did, '@localhost');
UPDATE project_issue_projects SET mail_digest = 'foo@localhost', mail_copy = 'foo@localhost';
UPDATE projects SET mail = CONCAT("empty", '@localhost');
UPDATE simplenews_subscriptions SET mail = CONCAT(snid, '@localhost');

UPDATE cvs_accounts SET pass = '';

-- Get rid of irrelevant data.
TRUNCATE accesslog;
TRUNCATE devel_queries;
TRUNCATE devel_times;
TRUNCATE directory;
TRUNCATE flood;
TRUNCATE history;
TRUNCATE mailhandler;
TRUNCATE search_dataset;
TRUNCATE search_index;
TRUNCATE search_total;
TRUNCATE search_node_links;
TRUNCATE sessions;
TRUNCATE watchdog;
TRUNCATE donations;
TRUNCATE old_revisions;
TRUNCATE access;

-- Remove sensitive variables and profile data
DELETE FROM variable WHERE name = 'drupal_private_key';
DELETE FROM variable WHERE name LIKE '%key%';

-- See http://drupal.org/node/862242 
TRUNCATE devel_queries;
TRUNCATE devel_times;
DROP TABLE bans;
DROP TABLE blog_seq;
DROP TABLE blog;
DROP TABLE book_seq;
DROP TABLE category;
DROP TABLE channel;
DROP TABLE chatevents;
DROP TABLE chatmembers;
DROP TABLE client_system;
DROP TABLE crons;
DROP TABLE diaries;
DROP TABLE entry;
DROP TABLE faqs;
DROP TABLE forum_seq;
DROP TABLE moderation_filters;
DROP TABLE page_seq;
DROP TABLE story_seq;
DROP TABLE topic;
DROP TABLE xapian_index_queue;
DROP TABLE client;
DROP TABLE directory;
DROP TABLE donations;
DROP TABLE dries_test;
DROP TABLE feature;
DROP TABLE forum2;
DROP TABLE google;
DROP TABLE moderation_roles;
DROP TABLE moderation_votes;
DROP TABLE old_revisions;
DROP TABLE notify;
DROP TABLE rating;
DROP TABLE smileys;
DROP TABLE sequences;
DROP TABLE test;
DROP TABLE project_releases;
DROP TABLE project_releases_backup;
