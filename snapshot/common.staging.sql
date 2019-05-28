TRUNCATE watchdog;

UPDATE users SET mail = concat(md5(name), '@sanitized.invalid');
UPDATE users SET init = if(init LIKE 'www.drupal.org/user/%/edit', replace(init, 'www.', 'www.staging.dev'), mail);
UPDATE authmap SET authname = concat(aid, '@sanitized.invalid');
