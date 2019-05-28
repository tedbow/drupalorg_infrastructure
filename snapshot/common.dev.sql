TRUNCATE history;
TRUNCATE authmap;

DELETE FROM users WHERE status <> 1 AND uid <> 0 AND name <> 'bacon';
UPDATE users SET data = '', pass = 'nope';
DELETE users_roles FROM users_roles LEFT JOIN users ON users_roles.uid = users.uid WHERE users.uid IS NULL;
