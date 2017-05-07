UPDATE comment SET mail = CONCAT(name, '@sanitized.invalid');
UPDATE multiple_email me INNER JOIN users u ON u.uid = me.uid SET me.email = concat(me.eid, '.', u.mail);
