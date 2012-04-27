UPDATE comments SET mail = CONCAT(name, '@sanitized.invalid') where mail != '';
UPDATE signup set forwarding_email = concat(nid, '@sanitized.invalid'), confirmation_email = '', reminder_email = '';
