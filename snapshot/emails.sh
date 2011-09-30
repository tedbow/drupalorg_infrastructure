pass=$1

echo "SELECT concat('UPDATE users SET mail = \"', mail, '\" WHERE name = ', name, ';') AS '' FROM users" | mysql -u dump -h db2-main-vip.drupal.org -p${pass} drupal | gzip > /var/dumps/mysql/${JOB_NAME}-in-progress.sql.gz
mv ${JOB_NAME}-in-progress.sql.gz ${JOB_NAME}.sql.gz
