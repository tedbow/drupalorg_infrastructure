TRUNCATE flood;
TRUNCATE sessions;

UPDATE users SET mail = CONCAT(name, uid, '@localhost'), init = CONCAT('http://drupal.org/user/', uid, '/edit');
UPDATE authmap SET authname = CONCAT(aid, '@localhost');
DELETE FROM variable WHERE name LIKE '%key%';
