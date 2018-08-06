-- Executed with mysql -f, every query will be executed, regardless of failure.
DROP TABLE access;
TRUNCATE accesslog;
TRUNCATE batch;
TRUNCATE devel_queries;
TRUNCATE devel_times;
TRUNCATE semaphore;
TRUNCATE votingapi_vote;
TRUNCATE election_vote;
TRUNCATE election_ballot;
TRUNCATE field_data_commerce_customer_address;
TRUNCATE field_revision_commerce_customer_address;
TRUNCATE commerce_payment_transaction;
TRUNCATE commerce_payment_transaction_revision;
TRUNCATE webform_emails;
TRUNCATE webform_submissions;
TRUNCATE webform_submitted_data;
