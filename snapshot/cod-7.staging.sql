UPDATE comment SET mail = CONCAT(name, '@sanitized.invalid');
UPDATE commerce_order SET mail = CONCAT(order_id, '@sanitized.invalid');
