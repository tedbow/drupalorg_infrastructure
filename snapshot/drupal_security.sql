-- CAUTION: DO NOT RUN THIS ON DATABASE WHERE YOU CARE ABOUT THE INFORMATION!!!

-- Munge emails for security.
UPDATE users SET mail = CONCAT(name, '@localhost'), init = CONCAT(name, '@localhost'), pass = MD5(CONCAT('security', name));
UPDATE comments SET mail = CONCAT(name, '@localhost');

-- Get rid of irrelevant data.
TRUNCATE accesslog;
TRUNCATE devel_queries;
TRUNCATE devel_times;
TRUNCATE search_dataset;
TRUNCATE search_index;
TRUNCATE search_total;

-- Remove sensitive variables
DELETE FROM variable WHERE name = 'drupal_private_key';
DELETE FROM variable WHERE name LIKE '%key%';
DELETE FROM profile_values WHERE fid IN (select fid from profile_fields where visibility in (1, 4));

