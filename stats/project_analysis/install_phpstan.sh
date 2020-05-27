#!/bin/bash

# This script will set up each of the drupal checkout directories to be ready to execute phpstan.
cd /var/lib/drupalci/workspace/drupal-checkouts
mkdir -p /var/lib/drupalci/workspace/phpstan-results
git clone -s /var/lib/drupalci/drupal-checkout drupal$1
cd /var/lib/drupalci/workspace/drupal-checkouts/drupal$1
COMPOSER_CACHE_DIR=/tmp/cache$1 sudo php -d sys_temp_dir=/var/lib/drupalci/workspace/drupal-checkouts/drupal$1 ./vendor/bin/drush si --db-url=sqlite://sites/default/files/.ht.sqlite -y
COMPOSER_CACHE_DIR=/tmp/cache$1 sudo php -d sys_temp_dir=/var/lib/drupalci/workspace/drupal-checkouts/drupal$1 ./vendor/bin/drush ./vendor/bin/drush en upgrade_status -y
git add sites/default/files/.ht.sqlite
git add .;git commit -q -m "add sqlite"
COMPOSER_CACHE_DIR=/tmp/cache$1 composer config prefer-stable false
