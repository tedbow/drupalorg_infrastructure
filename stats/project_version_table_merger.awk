#!/usr/bin/env -S mawk -f

 # Takes in fastly syslog entries and creates daily aggregate counts for download statistics
 # A sample line looks like the following:
 # 2015-06-27T00:00:00Z cache-ams4140 fastlyupdates[310]: 144.76.104.230 | "-" | "-" | 2015-06-26 | 23:59:59 +0000 | GET /release-history/metatag/7.x?site_key=IPfiGkPnKUfj6HIFgEQXFo0JyCXwfP5R9QQZxMCLJJA&version=7.x-1.5&list=metatag%2Cmetatag_context | 200 | (null) | Drupal (+http://drupal.org/)

 BEGIN {
        FS=",";
        OFS=",";
        }



  { # Only operate on lines with files/projects in them - ignore translations
  # if the record number in the file is equal to the total records processed, we're still in the first file
  # which is our master
 if ( FNR==NR ) {
     # a project_version_table record looks like this:
     # sitekey, project_machine_name, version, first seen, last seen, count
     #4V82tMqQqb_b0cdO0YUd3R0Bpt6AG6c341d4rB1fv9Q,views,7.x-3.7,1489388233,1489388233,1
     firstseen[$1,$2,$3] = $4;
     lastseen[$1,$2,$3] = $5;
     seencount[$1,$2,$3] = $6;
     next;
   }
   {
     if (firstseen[$1,$2,$3] > $4) {
       firstseen[$1,$2,$3] = $4;
     }
     if (lastseen[$1,$2,$3] < $5) {
            lastseen[$1,$2,$3] = $5;
     }
     seencount[$1,$2,$3] += $6;
   }
 }

 END {
   for (key in firstseen) {
   split(key, separated, SUBSEP);
       print separated[1],separated[2],separated[3],firstseen[key],lastseen[key],seencount[key];
   }

 }
