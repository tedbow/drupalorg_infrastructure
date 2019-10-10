#!/usr/bin/mawk -f

# to process all the split files, execute this from the filename dir in splits:
# /data/stats/updatestats/splits/sample.log
# find ./hosts/ -name "*.log" -exec /usr/local/drupal-infrastructure/stats/NG/hostprocessor.awk {} \;

function basename(file, a, n) {
    n = split(file, a, "/")
    return a[n]
  }

 BEGIN {
        FS=",";
        OFS=",";
         #blow away any existing files for this filename, in case we reprocess.
         # FILENAME isnt available in BEGIN blocks. Because magic.
         # MOve these to the encapsulating shell script
#         system("rm -rf /data/stats/updatestats/sitemodel/hosts/" basename(ARGV[1]) ".host_table");
#         system("rm -rf /data/stats/updatestats/sitemodel/hostsites/" basename(ARGV[1]) ".host_site_table");
        # print ARGV[1];
        }

  {


   entry_timestamp = $1;
   ipaddress = $2;
   site_key = $3;

   # Save an array of table keys
   host_keys[ipaddress] = 1;
   if (host_table[ipaddress,"earliest"] == "") {
     host_table[ipaddress,"earliest"] = entry_timestamp;
   }
   if (host_table[ipaddress,"earliest"] > entry_timestamp) {
       host_table[ipaddress,"earliest"] = entry_timestamp;
   }
   if (host_table[ipaddress,"latest"] < entry_timestamp) {
       host_table[ipaddress,"latest"] = entry_timestamp;
   }

   host_table[ipaddress,"count"]++;

   #sometimes we do not get a site key
   if (length(site_key) == 0) {
     next;
   }

   host_site_keys[ipaddress,site_key] = 1;
   site_keys[site_key] = 1;

   if (host_site_table[ipaddress,site_key,"earliest"] == "") {
        host_site_table[ipaddress,site_key,"earliest"] = entry_timestamp;
      }
   if (host_site_table[ipaddress,site_key,"earliest"] > entry_timestamp) {
     host_site_table[ipaddress,site_key,"earliest"] = entry_timestamp;
   }
   if (host_site_table[ipaddress,site_key,"latest"] < entry_timestamp) {
     host_site_table[ipaddress,site_key,"latest"] = entry_timestamp;
   }

   host_site_table[ipaddress,site_key,"count"]++;

   # The assumption is that the log files are in descending order, and that
   # the last time we see a record is also the latest time we see it.
   # update the counts


 }

 END {
  # Print out the hosts table:
   #Host Table
   #IP Address, IP First Seen, IP Last Seen, IP Count of visits
   for (ip_key in host_keys) {
       print ip_key,host_table[ip_key,"earliest"],host_table[ip_key,"latest"],host_table[ip_key,"count"] >> ("/data/stats/updatestats/sitemodel/processing/host/" basename(FILENAME) ".host_table");
   }

   for (ip_site_key in host_site_keys) {
     split(ip_site_key, separated, SUBSEP);
     print separated[1],separated[2],host_site_table[ip_site_key,"earliest"],host_site_table[ip_site_key,"latest"],host_site_table[ip_site_key,"count"] >> ("/data/stats/updatestats/sitemodel/processing/host_site/" basename(FILENAME) ".host_site_table");
   }

 }
