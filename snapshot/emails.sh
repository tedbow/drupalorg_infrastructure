pass=$1

echo "SELECT concat('UPDATE users SET mail = \"', mail, '\" WHERE name = ', name, ';') AS '' FROM users" | mysql -u dump -h db2-main-vip.drupal.org -p${pass} drupal | gzip > ${JOB_NAME}.sql.gz
mv ${JOB_NAME}.sql.gz /var/dumps/mysql/
