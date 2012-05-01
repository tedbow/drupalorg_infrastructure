UPDATE comments SET mail = CONCAT(name, '@sanitized.invalid');
DELETE FROM actions WHERE callback = 'pifr_server_notification_email_action';
