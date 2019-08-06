set -uex

cd /usr/local/api.drupal.org-src
for d in $(ls); do
  cd $d
  git pull
  if echo $d | grep -q '^drupal-8' && [ -f 'composer.json' ]; then
    composer install --prefer-dist --no-interaction --ignore-platform-reqs
  fi
  cd ..
done
