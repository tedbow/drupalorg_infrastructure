UPDATE users SET mail = CONCAT(name, uid, '@localhost'), init = CONCAT('http://drupal.org/user/', uid, '/edit');
UPDATE authmap SET authname = CONCAT(aid, '@localhost');
