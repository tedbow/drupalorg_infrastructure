UPDATE content_type_association_membership_benefit SET field_assoc_benefit_code_value = 'DrupalDrupalDrupal', field_assoc_benefit_link_url = 'http://example.com/';

TRUNCATE civicrm_drupal_username_sync;
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
DELETE FROM uc_coupons WHERE status <> 0;
TRUNCATE uc_coupons_orders;
TRUNCATE donations;

-- Remove sensitive variables
DELETE FROM variable WHERE name LIKE '%authnet%';
DELETE FROM variable WHERE name LIKE '%dfp_api%';
DELETE FROM profile_value WHERE fid IN (select fid from profile_field where visibility in (1, 4));

-- Unpublished content
DELETE FROM node WHERE status <> 1 AND type NOT IN ('product', 'association_training');
DELETE FROM comment WHERE status <> 0;

-- Depending tables
DELETE node FROM node LEFT JOIN users ON node.uid = users.uid WHERE users.uid IS NULL;
DELETE node_access FROM node_access LEFT JOIN node ON node.nid = node_access.nid WHERE node.nid IS NULL;
DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid WHERE node.nid IS NULL;
DELETE content_type_association_membership_benefit FROM content_type_association_membership_benefit LEFT JOIN node ON node.nid = content_type_association_membership_benefit.nid WHERE node.nid IS NULL;
DELETE book FROM book LEFT JOIN node ON node.nid = book.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN node ON node.nid = comment.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN users ON comment.uid = users.uid WHERE users.uid IS NULL;
DELETE comment FROM comment LEFT JOIN comment c2 ON comment.pid = c2.cid WHERE c2.cid IS NULL AND comment.pid <> 0;
DELETE files FROM files LEFT JOIN users ON files.uid = users.uid WHERE users.uid IS NULL;
DELETE files FROM files INNER JOIN field_data_upload upload ON files.fid = upload.upload_fid LEFT JOIN node ON upload.entity_id = node.nid WHERE upload.upload_fid IS NULL;
DELETE upload FROM field_data_upload upload LEFT JOIN node ON upload.entity_id = node.nid WHERE node.nid IS NULL;
DELETE file_managed FROM file_managed LEFT JOIN users ON file_managed.uid = users.uid WHERE users.uid IS NULL;

-- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
DELETE f FROM field_revision_comment_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
DELETE f FROM field_data_comment_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
DELETE f FROM field_revision_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
DELETE f FROM field_data_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
