#!/bin/bash

## This script  can be ran inside of a docker container or on a host
## behat must be in the PATH
## a user can be specified by prepending BDDUSER=<USERNAME>
## cd /home/behat/data
## BDDUSER=testuser ./run-bdd-tests.sh dev drupal testuer1
## ./run-bdd-tests.sh staging drupal

# server of testing
server=${1}
site=${2}
name=${3}

[ -z ${DOMAIN} ] && DOMAIN='devdrupal.org'
[ -z ${BASICAUTH} ] && BASICAUTH='drupal:drupal@'

function write_template {
  # Change bdduser to BDDUSER if variable is set
  if [[ ! -z ${BDDUSER} ]]; then
    sed -e "s#|SERVER|#${server}#g;s#|NAME|#${name}#g;s#|ROOT|#${root}#g;s#|SITE|#${site}#g;s#|TESTINGURI|#${testinguri}#g;s#|URI|#${URI}#g;s#bdduser#${BDDUSER}#g" "${1}" > "${2}"
  else
    sed -e "s#|SERVER|#${server}#g;s#|NAME|#${name}#g;s#|ROOT|#${root}#g;s#|SITE|#${site}#g;s#|TESTINGURI|#${testinguri}#g;s#|URI|#${URI}#g" "${1}" > "${2}"
  fi
}
URI=""
if [[ 'dev' = ${server} ]]; then
  URI="${name}-${site}.${server}.${DOMAIN}"
  root="/var/www/dev/${URI}/htdocs"
else
  if [[ 'drupal' = ${site} ]]; then
    SUBDOMAIN="${server}"

  else
    SUBDOMAIN="${site}.${server}"
  fi
  name="${server}"
  URI=${SUBDOMAIN}.${DOMAIN}
  root="/var/www/${URI}/htdocs"
fi

testinguri="https://${BASICAUTH}${URI}"

# Update drushrc
[ ! -d $HOME/.drush ] && mkdir $HOME/.drush
write_template "../drush/bdd.aliases.drushrc.php" "$HOME/.drush/bdd.aliases.drushrc.php"
# Update behat.local.yml
write_template 'behat.local.yml.example' 'behat.local.yml'

if [[ ! -z ${BDDDEBUG} ]]; then
  cat $HOME/.drush/bdd.aliases.drushrc.php
  echo ""
  cat behat.local.yml
  echo ""
  echo "behat --format junit --out ./build/ --config behat-${site}.yml"
  echo ""
fi

if [ 'dev' != "${server}" ] && [ 'drupal' = ${site} ]; then
  # disable tfa
  drush @${name}-${site} dis -y tfa
fi

[ ! -d "./build" ] && mkdir ./build
# Run behat
behat --format junit --out ./build/ --config behat-${site}.yml

if [ 'dev' != "${server}" ] && [ 'drupal' = ${site} ]; then
  # enable tfa
  drush @${name}-${site} en -y tfa tfa-basic drupalorg_permissions
fi

