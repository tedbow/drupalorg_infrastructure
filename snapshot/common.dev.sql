TRUNCATE history;
TRUNCATE watchdog;
TRUNCATE authmap;
TRUNCATE blocked_ips;

DELETE FROM users WHERE status <> 1 AND uid <> 0;
UPDATE users SET data = '', pass = 'nope';
UPDATE users SET mail = CONCAT(uid, "@nomail.invalid");
DELETE users_roles FROM users_roles LEFT JOIN users ON users_roles.uid = users.uid WHERE users.uid IS NULL;
