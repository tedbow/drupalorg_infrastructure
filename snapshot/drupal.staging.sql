UPDATE comments SET mail = CONCAT(name, '@sanitized.invalid');
UPDATE project_issue_projects SET mail_digest = 'foo@sanitized.invalid', mail_copy = 'foo@sanitized.invalid';
UPDATE projects SET mail = CONCAT("empty", '@sanitized.invalid');
UPDATE simplenews_subscriptions SET mail = CONCAT(snid, '@sanitized.invalid');
UPDATE multiple_email me INNER JOIN users u ON u.uid = me.uid SET me.email = concat(me.eid, '.', u.mail);
