UPDATE users SET access = 280299600;

DELETE FROM node WHERE status <> 1;

DELETE FROM comment WHERE status <> 1;
UPDATE comment SET hostname = '127.0.0.1';

DELETE node FROM node LEFT JOIN users ON node.uid = users.uid WHERE users.uid IS NULL;
DELETE node_access FROM node_access LEFT JOIN node ON node.nid = node_access.nid WHERE node.nid IS NULL;
DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid WHERE node.nid IS NULL;

DELETE comment FROM comment LEFT JOIN node ON node.nid = comment.nid WHERE node.nid IS NULL;
DELETE comment FROM comment LEFT JOIN users ON comment.uid = users.uid WHERE users.uid IS NULL;
DELETE comment FROM comment LEFT JOIN comment c2 ON comment.pid = c2.cid WHERE c2.cid IS NULL AND comment.pid <> 0;

-- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
DELETE f FROM field_revision_comment_body AS f LEFT JOIN comment c ON f.entity_id = c.cid WHERE c.cid IS NULL;
DELETE f FROM field_data_comment_body AS f LEFT JOIN comment c ON f.entity_id = c.cid WHERE c.cid IS NULL;
DELETE f FROM field_revision_body AS f LEFT JOIN node n ON f.entity_id = n.nid WHERE f.entity_type = 'node' AND n.nid IS NULL;
DELETE f FROM field_data_body AS f LEFT JOIN node n ON f.entity_id = n.nid WHERE f.entity_type = 'node' AND n.nid IS NULL;
