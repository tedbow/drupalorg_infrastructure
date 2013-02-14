#!/usr/bin/env bash

# Use rsync to make copies of files directories available for staging and dev.

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# 24 is vanished source files, as in deleted before syncing completes. Retry
# when this happens.
status=24
while [ ${status} = 24 ]; do
  rsync -av --exclude=tmp/ /var/www/drupal.org/htdocs/files/ /var/www/staging.devdrupal.org/htdocs/files/
  status=$?
done

exit ${status}
