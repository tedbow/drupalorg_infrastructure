#!/bin/bash

level=${1}
site=${2}
name=${3}

DOMAIN='devdrupal.org'
BASICAUTH='drupal:drupal'

function write_template {
  sed -e "s|LEVEL|${level}|g;s|NAME|${name}|g;s|ROOT|${root}|g;s|SITE|${site}|g;s|TESTINGURI|${testinguri}|g" "${1}" > "${2}"
}

if [[ 'dev' = ${level} ]]; then
  URL="${name}-${site}.${level}.${DOMAIN}"
  root="/var/www/dev/${URL}/htdocs"
else
  echo "line 18"
  if [[ 'drupal' = ${site} ]]; then
    echo "line 20"
    SUBDOMAIN="${level}"

  else
    SUBDOMAIN="${site}.${level}"
  fi
  name="${level}"
  URL=${SUBDOMAIN}.${DOMAIN}
  root="/var/www/${URL}/htdocs"
fi

testinguri="https://${BASICAUTH}@$URL"

# Update drushrc
write_template "../drush/bdd.aliases.drushrc.php" "$HOME/.drush/bdd.aliases.drushrc.php"
# Update behat.local.yml
write_template 'behat.local.yml.example' 'behat.local.yml'

cat $HOME/.drush/bdd.aliases.drushrc.php
echo ""
cat behat.local.yml

# Run behat
#bin/behat --dry-run --config behat-${level}.yml
