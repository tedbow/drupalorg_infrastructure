#!/bin/env bash

# Deploy a new version of drush for use by drush make during distribution
# packaging.

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Set the umask to 0002 so that files are added with 664/-rw-rw-r-- perms umask
# on www1 is defaulting to 0077 for some reason (even though the default is
# 0022)
umask 0002

cd "/var/www/drupal.org/tools/${tool-}"
git fetch
git checkout "${git_id-}"
git merge "origin/${git_id-}"
