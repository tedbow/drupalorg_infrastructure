UPDATE comment SET mail = CONCAT(name, '@sanitized.invalid');
UPDATE donations SET mail = CONCAT(did, '@sanitized.invalid');
UPDATE contact SET recipients = 'noreply@sanitized.invalid';
UPDATE commerce_order SET mail = CONCAT(order_id, '@sanitized.invalid');
