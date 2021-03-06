#!/bin/bash
set -uex
export PATH=$PATH:/usr/local/bin
export TERM=dumb

cd /data/logs/fastly/varnish-syslogs

# Look for files that have not yet been processed, and ignore todays file.
for filename in *[^gz]; do
   if [ ! -f "/data/stats/downloadstats/projects/${filename%fastly}downloadcounts.csv" ] && [ $filename != $(date +%Y.%m.%d.fastly) ]; then
     /usr/local/drupal-infrastructure/stats/fastlycounts.awk $filename
   fi;
done

# Create the comprehensive download counts
/usr/local/drupal-infrastructure/stats/downloadcount_aggregator.awk /data/stats/downloadstats/projects/*.downloadcounts.csv <(/bin/gzip -dc /data/stats/downloadstats/projects/*.downloadcounts.csv.gz)
