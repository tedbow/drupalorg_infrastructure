-- CAUTION: DO NOT RUN THIS ON DATABASE WHERE YOU CARE ABOUT THE INFORMATION!!!

-- Remove sensitive variables
DELETE FROM profile_values WHERE fid IN (select fid from profile_fields where visibility in (1, 4));
