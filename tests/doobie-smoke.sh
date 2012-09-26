#!/bin/sh

set -uex

[ "true" = "${REBUILD_DOOBIE}" ] && rm -rf doobie

if [ ! -d doobie ]; then
  # (re-)init the doobie repo
  git clone --branch master http://git.drupal.org/project/doobie.git
  cd doobie
  curl -s http://getcomposer.org/composer.phar > composer.phar
  php composer.phar install

  # set up the local yaml file

    cat behat.local.yml.tmpl | sed -e 's/|SITEUSERPW|/siteuser1/' \
    -e 's/|GITUSERPW|/gituser1/' \
    -e 's/|GITVETTEDUSERPW|/gitvetteduser1/' \
    -e 's/|DOCSMANAGERPW|/docsmanager1/' \
    -e 's/|ADMINTESTPW|/correct drupal battery staple/' \
    -e "s@|BASE_URL|@${URI:='http://git6staging.devdrupal.org'}@" \
    -e 's/|DRUSHALIAS|/myalias/' > behat.local.yml
else
  cd doobie
  git pull
fi

#bin/behat --tags="ci" --no-ansi -f junit --out results
bin/behat --tags="ci"
