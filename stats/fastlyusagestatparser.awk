#!/usr/bin/mawk -f

# Takes in fastly syslog entries and creates daily aggregate counts for download statistics
# A sample line looks like the following:
# 2015-06-27T00:00:00Z cache-ams4140 fastlyupdates[310]: 144.76.104.230 | "-" | "-" | 2015-06-26 | 23:59:59 +0000 | GET /release-history/metatag/7.x?site_key=IPfiGkPnKUfj6HIFgEQXFo0JyCXwfP5R9QQZxMCLJJA&version=7.x-1.5&list=metatag%2Cmetatag_context | 200 | (null) | Drupal (+http://drupal.org/)

BEGIN {FS="|";
       OFS="|";
       } # Split line on pipes

 { # Only operate on lines with files/projects in them - ignore translations
   # split incoming data for ip address
   # Trim leading spaces from date field
      gsub(/^[ \t]+/,"",$4);
      # Trim trailing spaces from date field
      gsub(/[ \t]+$/,"",$4);
      # Split date components into individual y/m/d parts

   if (lastdate != $4) {
        split($4,dateparts,"-");
        entry_timestamp =  mktime(dateparts[1] " " dateparts[2] " " dateparts[3] " " 0 " " 0 " " 0);
        dayofweek = sprintf("%02d",(dateparts[3] - strftime("%w",entry_timestamp)));
        week_timestamp = mktime(dateparts[1] " " dateparts[2] " " dayofweek  " " 0 " " 0 " " 0);
        system("mkdir -p /data/logs/updatestats/reformatted/" week_timestamp);
        lastdate = $4;
   }

   split($1,metadata," ");
   ipaddress = metadata[4];
   # split request line on spaces
   split($6,request," ");
   # split the url into request and querystring
   split(request[2], urlparts, "?");
   # split the request into project and version
   gsub(/release-history\/\//,"release-history/",urlparts[1]);
   split(urlparts[1], urlfields, "/");
   project = urlfields[3];
   api_version = urlfields[4];
   projects[project]=1;

   split(urlparts[2],qsvars,"&");

   split(qsvars[1], site_key, "=");
   split(qsvars[2], version, "=");

   # sometimes version isnt second, 'list' is, but no version.
   if (version[1] != 'version' ) {
     next;
   }

   # converts dev releases to nearest full release
   # split(version[2], realversion, "%");
   # fixedversion = realversion[1];

   # Convert dev releases to dev releases, not full releases.
   gsub(/\.[0-9].*%2B[0-9]+-dev$/,".x-dev", version[2]);
   fixedversion = version[2];

   if (length(site_key[2]) != 0) {
     print site_key[2],project,fixedversion,api_version >> ("/data/logs/updatestats/reformatted/" week_timestamp "/" FILENAME ".formatted");
   } else {
     print ipaddress,project,fixedversion,api_version >> ("/data/logs/updatestats/keyless/" week_timestamp "/" FILENAME ".nokey");
   }
}
