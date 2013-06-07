UPDATE comments SET mail = CONCAT(name, '@sanitized.invalid');
DELETE FROM actions WHERE callback = 'pifr_server_notification_email_action';

-- Stop active tests in progress
UPDATE pifr_test SET status = 4, last_requested = unix_timestamp(), last_tested = unix_timestamp() WHERE test_id IN (SELECT test_id FROM pifr_environment_status);

-- Generate placeholder results for any tests in progress (Note: Will throw 3 warnings!)
INSERT INTO pifr_result (test_id) SELECT test_id from pifr_environment_status WHERE 1;

-- Datafill placeholder results for any tests in progress
UPDATE pifr_result pr, pifr_environment_status pes SET pr.environment_id = 1, pr.code = 1, pr.details = 'a:1:{s:7:"@reason";s:43:"Test cancelled by admin prior to completion";}' WHERE pr.test_id = pes.test_id;

-- Clear tests in progress from pifr_environment_status
DELETE FROM pifr_environment_status WHERE 1;

-- Clear any confirmation tests in progress.
DELETE FROM pifr_client_test WHERE 1;

-- disable all testbots
UPDATE pifr_client SET status = 1 WHERE 1;

-- enable staging/dev bots
UPDATE pifr_client SET status = 4 WHERE client_id IN (973, 988);
