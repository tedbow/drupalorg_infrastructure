UPDATE comment SET mail = CONCAT(name, '@localhost');
UPDATE project_issue_projects SET mail_digest = 'foo@localhost', mail_copy = 'foo@localhost';
UPDATE projects SET mail = CONCAT("empty", '@localhost');
UPDATE simplenews_subscriptions SET mail = CONCAT(snid, '@localhost');
UPDATE multiple_email me INNER JOIN users u ON u.uid = me.uid SET me.email = concat(me.eid, '.', u.mail);
