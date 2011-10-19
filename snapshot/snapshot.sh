#!/bin/bash


# Make sure we have required db info
if [ $# -lt 4 ]; then
  echo "Usage: $0 db_name db_user db_pass tmp_pass [export_path]"
  echo "Where db_name is drupal, drupal_association, drupal_atrium, drupal_groups, drupal_redesign or drupal_security."
  exit 1
fi

# Make sure these exist, otherwise bad things happen
if [ ! $JOB_NAME ] || [ ! $BUILD_TAG ]; then
  echo "\$JOB_NAME or \$BUILD_TAG not defined, make sure to export these variables"
  exit 1
fi

# Configure credentials
db_user=$2
db_pass=$3

tmp_db=drupal_sanitize
tmp_user=sanitize_rw
tmp_pass=$4
tmp_host=db4-static.drupal.org

if [ $5 ]; then
  export_path=$(echo $5 | sed -e "s/\/*$//")
else
  export_path=/var/dumps/mysql
fi
ln -sf /var/dumps $WORKSPACE/dumps

# Configure variables used in the sanitization based on $db_name
case "$1" in
  drupal)
    db_name=drupal
    db_host=db2-main-vip.drupal.org
    sane_sql=drupal.sql
    ;;
  drupal_git_dev)
    db_name=drupal
    db_host=db2-main-vip.drupal.org
    sane_sql=git-dev.sql
    ;;
  drupal_association)
    db_name=drupal_association
    db_host=db3-vip.drupal.org
    sane_sql=association.sql
    ;;
  drupal_atrium)
    db_name=drupal_atrium
    db_host=db3-vip.drupal.org
    tmp_db=atrium_sanitize
    sane_sql=atrium.sql
    ;;
  drupal_groups)
    db_name=drupal_groups
    db_host=db3-vip.drupal.org
    tmp_db=groups_sanitize
    sane_sql=groups.sql
    ;;
  drupal_redesign)
    db_name=drupal_redesign
    db_host=db3-vip.drupal.org
    sane_sql=drupal.sql
    ;;
  drupal_security)
    db_name=drupal_security
    db_host=db3-vip.drupal.org
    tmp_db=security_sanitize
    sane_sql=security.sql
    ;;
  chicago2011)
    db_name=chicago2011
    db_host=db3-vip.drupal.org
    tmp_db=chicago2011_sanitize
    sane_sql=chicago.sql
    ;;
  chicago2011_scratch)
    db_name=chicago2011_scratch
    db_host=db3-vip.drupal.org
    tmp_db=chicago2011_sanitize
    sane_sql=chicago.sql
    ;;
  london2011)
    db_name=london2011
    db_host=db3-vip.drupal.org
    tmp_db=london2011_sanitize
    sane_sql=cod.sql
    ;;
  denver2012)
    db_name=denver2012
    db_host=db3-vip.drupal.org
    tmp_db=denver2012_sanitize
    sane_sql=cod-7.sql
    ;;
  munich2012)
    db_name=munich2012
    db_host=db3-vip.drupal.org
    tmp_db=munich_sanitize
    sane_sql=cod-7.sql
    ;;
  localize)
    db_name=drupal_localize
    db_host=db3-vip.drupal.org
    sane_sql=localize.sql
    ;;
  *)
    echo $"Usage: $0 db_name db_user db_pass db_host tmp_pass [export_path]"
    echo "Where db_name is drupal, drupal_association, drupal_groups, drupal_redesign or drupal_security."
    exit 1
esac

tmp_args="-h${tmp_host} -u${tmp_user} -p${tmp_pass} ${tmp_db}"

# Since we've made it here, we can start sanitizing the db
echo "Creating temporary database"
mysqldump -h$db_host -u$db_user -p$db_pass --single-transaction $db_name 2> mysqldump-errors.txt | mysql -o ${tmp_args}
[ -s mysqldump-errors.txt ] && exit 1

echo "Sanitizing temporary database"
cat sanitize/$sane_sql | mysql -o ${tmp_args} || exit 1

echo "Clearing cache tables"
echo "SHOW TABLES LIKE '%cache%';" | mysql -o ${tmp_args} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | mysql -o ${tmp_args}

if [ $db_name == "drupal_redesign" ]; then
  echo "Reducing DB size"
  cat sanitize/drupal-reduce-dump.sql | mysql -o ${tmp_args}
fi

echo "Creating $db_name database dump"
mysqldump --single-transaction ${tmp_args} | gzip > $export_path/$BUILD_TAG-in-progress.sql.gz || exit 1
mv $export_path/$BUILD_TAG-in-progress.sql.gz $export_path/$BUILD_TAG.sql.gz
ln -sf $export_path/$BUILD_TAG.sql.gz $export_path/$JOB_NAME-current.sql.gz

echo "Removing old database dump"
cd $export_path
rm `ls -t jenkins-${JOB_NAME}*.sql.gz | tail -n +3` > /dev/null 2>&1

echo "Clearing out temporary database"
echo "DROP DATABASE ${tmp_db}; CREATE DATABASE ${tmp_db};" | mysql -h$tmp_host -u$tmp_user -p$tmp_pass
