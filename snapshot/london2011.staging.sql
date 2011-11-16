UPDATE comments SET mail = CONCAT(name, '@localhost');
DELETE FROM variable WHERE name = 'regonline_account_password';
