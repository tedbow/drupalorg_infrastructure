#!/usr/bin/env bash

# Use rsync to make copies of files directories available for staging and dev.

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Use || to catch failure before set -e.
status=0
rsync -av --exclude=tmp/ /var/www/drupal.org/htdocs/files/ /var/www/staging.devdrupal.org/htdocs/files/ || status=$?

# 24 is vanished source files, as in deleted before syncing completes.
[ ${status} = 24 ] && exit 0

# Otherwise, exit with the real status.
exit ${status}

