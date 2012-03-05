-- CAUTION: DO NOT RUN THIS ON DATABASE WHERE YOU CARE ABOUT THE INFORMATION!!!

-- Munge emails for security.
UPDATE users_access SET access = 280299600;

-- Get rid of irrelevant data.
TRUNCATE modr8_log;
TRUNCATE role_activity;

-- We don't publicly share who has voted on what, if someone needs votes for theming they can do some votes.
TRUNCATE poll_votes;

-- Remove sensitive variables
DELETE FROM profile_values WHERE fid IN (select fid from profile_fields where visibility in (1, 4));

-- Remove notifications FUN
TRUNCATE notifications_queue;
TRUNCATE notifications_sent;
TRUNCATE notifications;
TRUNCATE notifications_fields;
TRUNCATE notifications_event;
TRUNCATE messaging_store;
TRUNCATE messaging_message_parts;


-- Remove unpublished/blocked core data
DELETE FROM node WHERE status = 0;
DELETE FROM comments WHERE status = 1;
DELETE FROM comments WHERE nid NOT IN (SELECT nid FROM node);
DELETE FROM comments WHERE uid NOT IN (SELECT uid FROM users);
DELETE FROM node_comment_statistics WHERE nid NOT IN (SELECT nid FROM node);
DELETE FROM node_revisions WHERE nid NOT IN (SELECT nid FROM node);
DELETE FROM node_counter WHERE nid NOT IN (SELECT nid FROM node);
DELETE FROM book WHERE nid NOT IN (SELECT nid FROM node);

-- Remove orphaned related data from contribs
DELETE FROM comment_upload WHERE cid NOT IN (SELECT cid FROM comments);
DELETE FROM apachesolr_search_node WHERE nid NOT IN (SELECT nid FROM node);
DELETE FROM content_field_organizers WHERE vid NOT IN (SELECT vid FROM node);
DELETE FROM content_field_type WHERE vid NOT IN (SELECT vid FROM node);
DELETE FROM content_type_event WHERE vid NOT IN (SELECT vid FROM node);
DELETE FROM content_type_image WHERE vid NOT IN (SELECT vid FROM node);
DELETE FROM content_type_job WHERE vid NOT IN (SELECT vid FROM node);
DELETE FROM content_type_og WHERE vid NOT IN (SELECT vid FROM node);
DELETE FROM content_type_page WHERE vid NOT IN (SELECT vid FROM node);
DELETE FROM content_type_poll WHERE vid NOT IN (SELECT vid FROM node);
DELETE FROM content_type_proposal WHERE vid NOT IN (SELECT vid FROM node);
DELETE FROM content_type_story WHERE vid NOT IN (SELECT vid FROM node);
DELETE FROM content_type_wikipage WHERE vid NOT IN (SELECT vid FROM node);

-- Get rid of more irrelvant data.
TRUNCATE node_counter;

-- Remove some data that's just not necessary
UPDATE signup set confirmation_email = '';
UPDATE signup_log SET form_data = 'a:0:{}';
