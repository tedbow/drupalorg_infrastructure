-- CAUTION: DO NOT RUN THIS ON DATABASE WHERE YOU CARE ABOUT THE INFORMATION!!!

-- Get rid of irrelevant data.
TRUNCATE accesslog;
TRUNCATE devel_queries;
TRUNCATE devel_times;
TRUNCATE search_dataset;
TRUNCATE search_index;
TRUNCATE search_total;

-- Remove sensitive variables
DELETE FROM profile_values WHERE fid IN (select fid from profile_fields where visibility in (1, 4));
