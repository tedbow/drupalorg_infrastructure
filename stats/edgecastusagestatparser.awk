#!/usr/bin/mawk -f

# Takes in fastly syslog entries and creates daily aggregate counts for download statistics
# A sample line looks like the following:
# 2015-06-27T00:00:00Z cache-ams4140 fastlyupdates[310]: 144.76.104.230 | "-" | "-" | 2015-06-26 | 23:59:59 +0000 | GET /release-history/metatag/7.x?site_key=IPfiGkPnKUfj6HIFgEQXFo0JyCXwfP5R9QQZxMCLJJA&version=7.x-1.5&list=metatag%2Cmetatag_context | 200 | (null) | Drupal (+http://drupal.org/)

# 75.119.222.166 - - [22/Jun/2015:23:59:52 +0000] "GET http://updates.drupal.org/80C301/updates.drupal.org/release-history/field_group_table/7.x?site_key=jzziGM7E2rLqT9SYM4K4kmQV2cjmnBr127pqMUXyH2g&version=7.x-1.5&list=field_group_table HTTP/1.1" 200 12636 "-" "Drupal (+http://drupal.org/)"
BEGIN {
       OFS="|";
       } # Split line on pipes

$7 ~ /updates\.drupal\.org/ { # Trim leading bracket from date field
   gsub(/^\[/,"",$4);

   # Split date components into individual y/m/d parts
   # Check if the date has changed, if so, recalculate new week and create subdir.
   if (lastdate != substr($4,0,11)) {
        split($4,dateparts,"/");
        split(dateparts[3],timeparts,":");
        monthnum = sprintf("%02d",(match("JanFebMarAprMayJunJulAugSepOctNovDec",dateparts[2])+2)/3);
        entry_timestamp = mktime(timeparts[1] " " monthnum " " dateparts[1] " " 0 " " 0 " " 0);
        dayofweek = sprintf("%02d",(dateparts[1] - strftime("%w",entry_timestamp)));
        week_timestamp = mktime(timeparts[1] " " monthnum " " dayofweek  " " 0 " " 0 " " 0);
        system("mkdir -p /data/logs/updatestats/reformatted/" week_timestamp);
        lastdate = substr($4,0,11);
   }


   split($7, urlparts, "?");
   # split the request into project and version
   gsub(/release-history\/\//,"release-history/",urlparts[1]);
   split(urlparts[1], urlfields, "/");
   project = urlfields[7];
   api_version = urlfields[8];
   projects[project]=1;

   split(urlparts[2],qsvars,"&");
   split(qsvars[1], site_key, "=");
   split(qsvars[2], version, "=");
   # converts dev releases to nearest full release
   # split(version[2], realversion, "%");
   # fixedversion = realversion[1];

   # Convert dev releases to dev releases, not full releases.
   gsub(/\.[0-9].*%2B[0-9]+-dev$/,".x-dev", version[2]);
   fixedversion = version[2];
   if (length(site_key[2]) != 0) {
     print site_key[2],project,fixedversion,api_version >> ("/data/logs/updatestats/reformatted/" week_timestamp "/" FILENAME ".formatted");
   } else {
     print $4,project,fixedversion,api_version >> ("/data/logs/updatestats/keyless/" week_timestamp "/" FILENAME ".nokey");
   }

}
