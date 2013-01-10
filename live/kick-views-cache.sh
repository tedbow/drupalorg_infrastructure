#!/usr/bin/env bash

# We've been experiencing views cache trouble, 404 instead of content, see
# http://drupal.org/node/1770434. Since we are on old versions, work around
# this, and monitor for patterns.

# Include common live script.
. live/common.sh 'kick-views-cache'

# Check if the hosting page returns an error. This is the
# most-frequently-noticed problem page. We are assuming this will catch
# problems with other pages.
if ! curl -f 'http://drupal.org/hosting' > /dev/null; then
  # Clear views cache
  ${drush} cc views
  # Exit with an error so Jenkins can keep a record of problems.
  exit 1
fi
