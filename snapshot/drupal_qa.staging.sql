UPDATE comments SET mail = CONCAT(name, '@sanitized.invalid');
DELETE FROM actions WHERE callback = 'pifr_server_notification_email_action';

-- Stop active tests in progress
UPDATE pifr_test SET status = 4, last_requested = unix_timestamp(), last_tested = unix_timestamp() WHERE test_id IN (SELECT test_id FROM pifr_environment_status);

-- Generate placeholder results for any tests in progress (Note: Will throw warnings!)
INSERT INTO pifr_result (test_id, environment_id, code, details) SELECT test_id, 1, 1, 'a:1:{s:7:"@reason";s:43:"Test cancelled by admin prior to completion";}' from pifr_environment_status WHERE 1;
INSERT INTO pifr_log (test_id, client_id, code, timestamp) SELECT test_id, client_id, 14, unix_timestamp() from pifr_environment_status WHERE 1;

-- Clear tests in progress from pifr_environment_status
DELETE FROM pifr_environment_status WHERE 1;

-- Clear any confirmation tests in progress.
DELETE FROM pifr_client_test WHERE 1;

-- disable all testbots
UPDATE pifr_client SET status = 1 WHERE 1;

-- enable staging/dev bots and project servers
UPDATE pifr_client SET status = 4 WHERE client_id IN (973, 988, 1578, 1583);

-- Update client confirmation variable to not require confirmation
UPDATE variable SET value = 's:2:"-1";' where name = 'pifr_server_client_test_interval';
