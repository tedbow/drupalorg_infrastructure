UPDATE comments SET mail = CONCAT(name, '@localhost') where mail != '';
UPDATE signup set forwarding_email = concat(nid, '@localhost'), confirmation_email = '', reminder_email = '';
