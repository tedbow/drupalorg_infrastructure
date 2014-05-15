# We don't actually want or need anything from common.sh so don't source it.
# However, at least printing what we're running is a help.
set -x

. live/webnodes.sh

domain_name="drupal.bak"

for i in ${webnodes[@]}; do
  if [ ${i} -eq 1 ]; then
    echo 'purge.url ^.*$' | nc www${i}.${domain_name} 8181
  else
    echo 'ban req.http.host != "updates.drupal.org" && req.url ~ "^.*$"' | nc www${i}.${domain_name} 8181
  fi
done
