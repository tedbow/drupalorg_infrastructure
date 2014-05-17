# We don't actually want or need anything from common.sh so don't source it.
# However, at least printing what we're running is a help.
set -x

. live/webnodes.sh

domain_name="drupal.bak"

for i in ${webnodes[@]}; do
  echo 'ban obj.http.x-host != "updates.drupal.org" && obj.http.x-url ~ "^.*$"' | nc www${i}.${domain_name} 8181
done
