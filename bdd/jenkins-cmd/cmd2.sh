#!/bin/bash

set -uex

cd /usr/local/drupal-infrastructure/bdd/behat

docker pull drupalorg/bdddrupalext

docker run --rm --link=selenium:selenium \
  -v /usr/local/drupal-infrastructure/bdd/drush:/home/behat/drush \
  -v $(pwd):/home/behat/data \
  -v /home/ubuntu/.ssh:/home/behat/.ssh \
  -v ${WORKSPACE}/build:/home/behat/data/build \
  drupalorg/bdddrupalext bash -c "BUILD_NUMBER=${BUILD_NUMBER} BDDDEBUG=1 ./run-bdd-tests.sh staging ${SITE}"
