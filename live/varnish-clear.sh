# We don't actually want or need anything from common.sh so don't source it.
# However, at least printing what we're running is a help.
set -x

. live/webnodes.sh

for i in ${webnodes[@]}; do
  ssh bender@www$i.drupal.org "varnishadm -T localhost:8181 'purge.url ^.*$'"
done
