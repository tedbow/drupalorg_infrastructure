UPDATE comment SET mail = CONCAT(name, '@sanitized.invalid');
UPDATE contact SET recipients = 'noreply@sanitized.invalid';
