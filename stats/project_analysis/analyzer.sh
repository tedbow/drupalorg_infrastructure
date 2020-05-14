#!/bin/bash
set -ux
function gitCommit() {
  cd $1
  git init
  git add .;git commit -q -m "git project before rector"
  cd -
}

cd /var/lib/drupalci/workspace/drupal-checkouts/drupal$5
#COMPOSER_CACHE_DIR=/tmp/cache$5 composer config repositories.patch vcs https://github.com/greg-1-anderson/core-relaxed
#COMPOSER_CACHE_DIR=/tmp/cache$5 composer --no-interaction --no-progress require drupal/core-relaxed 8.8.x 2> /var/lib/drupalci/workspace/phpstan-results/$1.$3.phpstan_stderr
COMPOSER_CACHE_DIR=/tmp/cache$5 composer --no-interaction --no-progress require drupal/$2 $3 2>> /var/lib/drupalci/workspace/phpstan-results/$1.$3.phpstan_stderr

sudo ~/.composer/vendor/bin/drush en $2 -y
sudo ~/.composer/vendor/bin/drush upgrade_status:checkstyle  $2 > /var/lib/drupalci/workspace/phpstan-results/$1.$3.upgrade_status.pre_rector.xml 2>> /var/lib/drupalci/workspace/phpstan-results/$1.$3.upgrade_status_stderr
# Only run rector if we have some file messages in the XML.
update_info=1;
create_patch=0;
php ./vendor/bin/rector_needed /var/lib/drupalci/workspace/phpstan-results/$1.$3.upgrade_status.pre_rector.xml
if [ $? -eq 0 ]; then
  # Rename phpstan.neon because it is not needed for rector and causes some modules to fail.
  mv phpstan.neon phpstan.neon.hide
  # Create a git commit for the current state of the project
  gitCommit ${4#project_}s/contrib/$2
  php -d memory_limit=2G -d sys_temp_dir=/var/lib/drupalci/workspace/drupal-checkouts/drupal$5 ./vendor/bin/rector process --verbose ${4#project_}s/contrib/$2 &>  /var/lib/drupalci/workspace/phpstan-results/$1.$3.rector_out
  cd ${4#project_}s/contrib/$2
  git diff > /var/lib/drupalci/workspace/phpstan-results/$1.$3.rector.patch
  # Delete the file if it is empty.
  find /var/lib/drupalci/workspace/phpstan-results/$1.$3.rector.patch -size  0 -print -delete
  # Restore phpstan.neon
  cd /var/lib/drupalci/workspace/drupal-checkouts/drupal$5
  mv phpstan.neon.hide phpstan.neon

  sudo ~/.composer/vendor/bin/drush upgrade_status:checkstyle  $2 > /var/lib/drupalci/workspace/phpstan-results/$1.$3.upgrade_status.post_rector.xml 2>> /var/lib/drupalci/workspace/phpstan-results/$1.$3.upgrade_status_stderr
  php ./vendor/bin/info_updatable /var/lib/drupalci/workspace/phpstan-results/$1.$3.upgrade_status.post_rector.xml
  if [ $? -eq 0 ]; then
    php ./vendor/bin/update_info ${4#project_}s/contrib/$2/$2.info
  fi
else
  php /vendor/bin/info_updatable /var/lib/drupalci/workspace/phpstan-results/$1.$3.upgrade_status.pre_rector.xml
  if [ $? -eq 0 ]; then
    php ./vendor/bin/update_info ${4#project_}s/contrib/$2/$2.info
  fi
fi


git reset --hard HEAD
git clean -ffd
