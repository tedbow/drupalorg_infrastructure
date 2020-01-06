#!/usr/bin/env bash
set -uex

cd /usr/local/api.drupal.org-src
for d in $(ls); do
  cd $d
  if [ "${shallow-}" = 'true' ]; then
    git pull --depth 1 && git gc --prune=all
  else
    git pull
  fi
  # Coder keeps ending up with local changes, get rid of them.
  if [ -d 'vendor/drupal/coder' ]; then
    pushd 'vendor/drupal/coder'
    git diff-index --quiet HEAD -- || git reset --hard
    popd
  fi
  if echo $d | grep -q '^drupal-8' && [ -f 'composer.json' ]; then
    php7.3 /usr/local/bin/composer install --prefer-dist --no-interaction --ignore-platform-reqs
  fi
  cd ..
done
