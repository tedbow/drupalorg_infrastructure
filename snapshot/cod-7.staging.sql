UPDATE comment SET mail = CONCAT(name, '@sanitized.invalid');
UPDATE ticket_reservation SET mail = CONCAT(trid, '@sanitized.invalid') WHERE mail IS NOT NULL;
UPDATE commerce_order SET mail = CONCAT(order_id, '@sanitized.invalid');
