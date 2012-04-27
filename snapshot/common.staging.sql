UPDATE users SET mail = CONCAT(name, uid, '@sanitized.invalid'), init = CONCAT('http://drupal.org/user/', uid, '/edit');
UPDATE authmap SET authname = CONCAT(aid, '@sanitized.invalid');
