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
        dayofweek = strftime("%w",entry_timestamp);
        week_timestamp = mktime(dateparts[1] " " dateparts[2] " " dateparts[3] - dayofweek  " " 0 " " 0 " " 0);
        system("mkdir -p /data/logs/updatestats/reformatted/" week_timestamp);
        lastdate = $4;
   }

   #split($1,metadata," ");
   #ipaddress = metadata[4];
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


   if (length(site_key[2]) != 0) {
     print site_key[2],project,version[2],api_version >> ("/data/logs/updatestats/reformatted/" week_timestamp "/" FILENAME);
   } else {
     print $4,project,version[2],api_version >> ("/data/logs/updatestats/reformatted/" week_timestamp "/" FILENAME ".nokey");
   }
   # pull out the filename, but trim off the initial slash
   #filename=substr(request[2],2);
   # Keep a count of times we see Y-M-D-Filename (just in case the file contains multiple days)
   #count[dateparts[1]","dateparts[2]","dateparts[3]","filename]++;
}
