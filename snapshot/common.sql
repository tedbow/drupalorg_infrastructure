TRUNCATE history;
TRUNCATE watchdog;
TRUNCATE authmap;

DELETE FROM users WHERE status <> 1 AND uid <> 0;
UPDATE users SET data = '';
