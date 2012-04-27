UPDATE comments SET mail = CONCAT(name, '@sanitized.invalid');
DELETE FROM variable WHERE name = 'regonline_account_password';
