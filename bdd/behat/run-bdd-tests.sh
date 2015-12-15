#!/bin/bash

# server of testing
server=${1}
site=${2}
name=${3}

DOMAIN='devdrupal.org'
BASICAUTH='drupal:drupal@'

function write_template {
  # Change bdduser to BDDUSER if variable is set
  if [[ ! -z ${BDDUSER} ]]; then
    sed -e "s#SERVER#${server}#g;s#NAME#${name}#g;s#ROOT#${root}#g;s#SITE#${site}#g;s#TESTINGURI#${testinguri}#g;s#bdduser#${BDDUSER}#g" "${1}" > "${2}"
  else
    sed -e "s#SERVER#${server}#g;s#NAME#${name}#g;s#ROOT#${root}#g;s#SITE#${site}#g;s#TESTINGURI#${testinguri}#g" "${1}" > "${2}"
  fi
}

if [[ 'dev' = ${server} ]]; then
  URL="${name}-${site}.${server}.${DOMAIN}"
  root="/var/www/dev/${URL}/htdocs"
else
  if [[ 'drupal' = ${site} ]]; then
    SUBDOMAIN="${server}"

  else
    SUBDOMAIN="${site}.${server}"
  fi
  name="${server}"
  URL=${SUBDOMAIN}.${DOMAIN}
  root="/var/www/${URL}/htdocs"
fi

testinguri="https://${BASICAUTH}$URL"

# Update drushrc
write_template "../drush/bdd.aliases.drushrc.php" "$HOME/.drush/bdd.aliases.drushrc.php"
# Update behat.local.yml
write_template 'behat.local.yml.example' 'behat.local.yml'

if [[ ! -z ${BDDDEBUG} ]]; then
  cat $HOME/.drush/bdd.aliases.drushrc.php
  echo ""
  cat behat.local.yml
  echo ""
  echo "bin/behat --config behat-${site}.yml"
fi

# Run behat
bin/behat --config behat-${site}.yml
