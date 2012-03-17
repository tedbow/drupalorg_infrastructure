# Sync the varnishlogs from all webnodes.

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Get list of webnodes
. live/webnodes.sh

varnish_logdir="/var/log/DROP"
domain_name="drupal.bak"
rsync_args="--delete --delete-excluded --exclude=transfer.log --include=*"

for i in ${webnodes[@]}; do
  nice -n 19 rsync -rt ${rsync_args} "www${i}.${domain_name}::varnishlogs/" "${varnish_logdir}/www${i}/"
done
