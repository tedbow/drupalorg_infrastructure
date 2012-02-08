-- CAUTION: DO NOT RUN THIS ON DATABASE WHERE YOU CARE ABOUT THE INFORMATION!!!

UPDATE content_type_association_membership_benefit SET field_assoc_benefit_code_value = 'DrupalDrupalDrupal', field_assoc_benefit_link_url = 'http://example.com/';

-- Get rid of irrelevant data.
TRUNCATE devel_queries;
TRUNCATE devel_times;
TRUNCATE batch;
TRUNCATE semaphore;
TRUNCATE search_dataset;
TRUNCATE search_index;
TRUNCATE search_total;
TRUNCATE access;
TRUNCATE mollom;

TRUNCATE civicrm_drupal_username_sync;
TRUNCATE votingapi_vote;
TRUNCATE webform_emails;
TRUNCATE webform_submissions;
TRUNCATE webform_submitted_data;

TRUNCATE uc_cart_products;
TRUNCATE uc_orders;
TRUNCATE uc_order_admin_comments;
TRUNCATE uc_order_comments;
TRUNCATE uc_order_line_items;
TRUNCATE uc_order_log;
TRUNCATE uc_order_products;
TRUNCATE uc_payment_check;
TRUNCATE uc_payment_cod;
TRUNCATE uc_payment_other;
TRUNCATE uc_payment_receipts;
TRUNCATE uc_coupons;
TRUNCATE uc_coupons_orders;

-- Remove sensitive variables
DELETE FROM variable WHERE name LIKE '%authnet%';
DELETE FROM variable WHERE name LIKE '%dfp_api%';
DELETE FROM profile_values WHERE fid IN (select fid from profile_fields where visibility in (1, 4));

-- Unpublished content
DELETE FROM node WHERE status <> 1 AND type NOT IN ('product', 'association_training');
DELETE FROM comments WHERE status <> 0;

-- Depending tables
DELETE node FROM node LEFT JOIN users ON node.uid = users.uid WHERE users.uid IS NULL;
DELETE node_access FROM node_access LEFT JOIN node ON node.nid = node_access.nid WHERE node.nid IS NULL;
DELETE node_revisions FROM node_revisions LEFT JOIN node ON node.nid = node_revisions.nid WHERE node.nid IS NULL;
DELETE content_type_association_membership_benefit FROM content_type_association_membership_benefit LEFT JOIN node ON node.nid = content_type_association_membership_benefit.nid WHERE node.nid IS NULL;
DELETE book FROM book LEFT JOIN node ON node.nid = book.nid WHERE node.nid IS NULL;
DELETE comments FROM comments LEFT JOIN node ON node.nid = comments.nid WHERE node.nid IS NULL;
DELETE comments FROM comments LEFT JOIN users ON comments.uid = users.uid WHERE users.uid IS NULL;
DELETE comments FROM comments LEFT JOIN comments c2 ON comments.pid = c2.cid WHERE c2.cid IS NULL AND comments.pid <> 0;
DELETE files FROM files LEFT JOIN users ON files.uid = users.uid WHERE users.uid IS NULL;
DELETE files FROM files INNER JOIN upload ON files.fid = upload.fid LEFT JOIN node ON upload.nid = node.nid WHERE upload.fid IS NULL;
DELETE upload FROM upload LEFT JOIN node ON upload.nid = node.nid WHERE node.nid IS NULL;
DELETE users_roles FROM users_roles LEFT JOIN users ON users_roles.uid = users.uid WHERE users.uid IS NULL;
