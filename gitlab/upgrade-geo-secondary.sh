#!/bin/bash
set -eux
# Make sure everything is in a proper state
gitlab-ctl reconfigure
# upgrade
gitlab-ctl stop sidekiq
gitlab-ctl stop geo-logcursor
apt-get update && apt-get install gitlab-ee
# post upgrade reconfigure
SKIP_POST_DEPLOYMENT_MIGRATIONS=true gitlab-ctl reconfigure
gitlab-rake geo:db:migrate
gitlab-ctl hup unicorn
gitlab-ctl hup sidekiq
gitlab-ctl restart geo-logcursor
gitlab-rake gitlab:geo:check
gitlab-rake geo:status
