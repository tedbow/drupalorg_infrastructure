UPDATE comments SET mail = CONCAT(name, '@localhost');
UPDATE donations SET mail = CONCAT(did, '@localhost');
UPDATE contact SET recipients = 'noreply@localhost';
