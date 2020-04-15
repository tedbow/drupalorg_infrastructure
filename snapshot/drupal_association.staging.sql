UPDATE comment SET mail = CONCAT(name, '@sanitized.invalid');
UPDATE donations SET mail = CONCAT(did, '@sanitized.invalid');
