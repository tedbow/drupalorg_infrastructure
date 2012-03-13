# We don't actually want or need anything from common.sh so don't source it.

# Currently, www4 doesn't exist.
webnodes=(1 2 3 5 6 7)

for i in ${webnodes[@]}; do
  ssh bender@www$i.drupal.org "varnishadm -T localhost:8181 'purge.url ^.*$'"
done
