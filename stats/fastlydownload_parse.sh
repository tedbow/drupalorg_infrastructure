export PATH=$PATH:/usr/local/bin
export TERM=dumb

cd /data/logs/fastly/varnish-syslogs

# Look for files that have not yet been processed, and ignore todays file.
for filename in *; do
   if [ ! -f "/data/logs/fastly/downloadcounts/${filename%fastly}downloadcounts.csv" ] && [ $filename != $(date +%Y.%m.%d.fastly) ]; then
     /usr/local/drupal-infrastructure/stats/fastlycounts.awk $filename
   fi;
done

# Create the comprehensive download counts
/usr/local/drupal-infrastructure/stats/downloadcount_aggregator.awk /data/logs/fastly/downloadcounts/*.downloadcounts.csv
