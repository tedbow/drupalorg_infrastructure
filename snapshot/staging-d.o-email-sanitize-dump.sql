UPDATE users SET mail = CONCAT(name, '@localhost'), init = CONCAT('http://drupal.org/user/', uid, '/edit');
UPDATE comments SET mail = CONCAT(name, '@localhost');
UPDATE authmap SET authname = CONCAT(aid, '@localhost');
UPDATE project_issue_projects SET mail_digest = 'foo@localhost', mail_copy = 'foo@localhost';
UPDATE projects SET mail = CONCAT("empty", '@localhost');
UPDATE simplenews_subscriptions SET mail = CONCAT(snid, '@localhost');
UPDATE multiple_email me INNER JOIN users u ON u.uid = me.uid SET me.email = concat(me.eid, '.', u.mail);
