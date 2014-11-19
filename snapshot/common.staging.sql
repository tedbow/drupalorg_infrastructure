UPDATE users SET mail = concat(md5(name), '@sanitized.invalid');
UPDATE users SET init = if(init LIKE 'drupal.org/user/%/edit', concat('staging.dev', init), mail);
UPDATE authmap SET authname = concat(aid, '@sanitized.invalid');
