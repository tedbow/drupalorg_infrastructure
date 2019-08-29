#!/usr/bin/env bash
set -uex

cd /usr/local/api.drupal.org-src
for d in $(ls); do
  cd $d
  git pull
  # Coder keeps ending up with local changes, get rid of them.
  if [ -d 'vendor/drupal/coder' ]; then
    pushd 'vendor/drupal/coder'
    git diff-index --quiet HEAD -- || git reset --hard
    popd
  fi
  if echo $d | grep -q '^drupal-8' && [ -f 'composer.json' ]; then
    composer install --prefer-dist --no-interaction --ignore-platform-reqs
  fi
  cd ..
done
