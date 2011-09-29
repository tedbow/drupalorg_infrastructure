export PATH=$PATH:/usr/local/bin
export TERM=dumb
domain=$1 # denver2012.scratch.drupal.org
db_site=$(echo $domain | sed -e 's/\..*$//') #denver2012
redesign_ro_pass=$2
drush="drush -r /var/www/${domain}/htdocs -l ${domain} -y"
db=$($drush sql-conf | sed -ne 's/^\s*\[database\] => //p')

# Repopulate DB
echo "DROP DATABASE ${db}; CREATE DATABASE ${db};" | $drush sql-cli
ssh util zcat /var/dumps/mysql/${db_site}_database_snapshot-current.sql.gz | $drush sql-cli

# Get ready for development
$drush pm-enable devel
$drush variable-set smtp_library sites/all/modules/devel/devel.module
$drush variable-set cache 0
$drush variable-set preprocess_css 0
$drush variable-set preprocess_js 0

# Un-sanitize the user table for bakery
mysql -uredesign_ro -p${redesign_ro_pass} -h db2-main-vip.drupal.org drupal --batch -e "SELECT concat('UPDATE users SET mail = \"', mail, '\" WHERE name = ', name, ';') AS '' FROM users" | $drush sql-cli

# Prime caches
wget -O /dev/null http://drupal:drupal@${domain}
