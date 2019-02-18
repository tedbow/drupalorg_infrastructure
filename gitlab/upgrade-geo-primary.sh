#!/bin/bash
set -eux
gitlab-ctl reconfigure
apt-get update && apt-get install gitlab-ee
SKIP_POST_DEPLOYMENT_MIGRATIONS=true gitlab-ctl reconfigure
SKIP_POST_DEPLOYMENT_MIGRATIONS=true gitlab-rake db:migrate
gitlab-rake db:migrate
gitlab-ctl hup unicorn
gitlab-ctl hup sidekiq
gitlab-rake gitlab:geo:check
