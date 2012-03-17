# Sync the varnishlogs from all webnodes

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

varnish_logdir="/var/log/DROP"
domain_name="drupal.bak"
rsync_args="--delete --delete-excluded --exclude=transfer.log --include=*"

for host in www{1..3} www{5..7}; do
  nice -n 19 rsync -rt ${rsync_args} ${host}.${domain_name}::varnishlogs/ ${varnish_logdir}/${host}/
done
