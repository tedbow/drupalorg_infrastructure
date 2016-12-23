#!/bin/bash -eux

date

DIR="/opt/drupalci_testbot"
DRUPAL_DIR="/opt/drupal_checkout"
COMPOSER_CACHE_DIR="/opt/composer_cache"
mkdir ${COMPOSER_CACHE_DIR}
git clone --branch production http://git.drupal.org/project/drupalci_testbot.git ${DIR}
composer install --prefer-dist --no-progress --working-dir ${DIR}

chmod 775 ${DIR}/drupalci
ln -s ${DIR}/drupalci /usr/local/bin/drupalci

# Lets prepopulate the composer cache
git clone http://git.drupal.org/project/drupal.git ${DRUPAL_DIR}
composer install --prefer-dist --no-progress --working-dir ${DRUPAL_DIR}
chown -R ubuntu:ubuntu ${COMPOSER_CACHE_DIR}
