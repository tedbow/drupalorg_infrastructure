#!/usr/bin/env -S mawk -f

 # Takes in fastly syslog entries and splits the files by IP address and site key to be able to parallelize and
 # handle memory better.
 # A sample line looks like the following:
 # 2015-06-27T00:00:00Z cache-ams4140 fastlyupdates[310]: 144.76.104.230 | "-" | "-" | 2015-06-26 | 23:59:59 +0000 | GET /release-history/metatag/7.x?site_key=IPfiGkPnKUfj6HIFgEQXFo0JyCXwfP5R9QQZxMCLJJA&version=7.x-1.5&list=metatag%2Cmetatag_context | 200 | (null) | Drupal (+http://drupal.org/)

# returns the filename portion of a full path.
function basename(file, a, n) {
    n = split(file, a, "/")
    return a[n]
  }

BEGIN {
         FS="|";
         #blow away any existing files for this filename, in case we reprocess.
         # FILENAME isnt available in BEGIN blocks. Because magic.
         #system("rm -rf /data/stats/updatestats/splits/" LOGFILENAME);
         #system("mkdir -p /data/stats/updatestats/splits/" LOGFILENAME);
         #system("mkdir -p /data/stats/updatestats/splits/" LOGFILENAME "/sites/" );
         #system("mkdir -p /data/stats/updatestats/splits/" LOGFILENAME "/hosts/" );
}
{
  split($1,parts," ");
  split(parts[4],octets,".");
  if (octets[1] == "(null)") {
    next;
  }

   gsub(/^<134>/,"",parts[1]);
   gsub(/[-:TZ]+/," ",parts[1]);
   entry_timestamp = mktime(parts[1]);
   if (entry_timestamp == -1) {
    print parts[1];
    next;
   }

   split($6, urlparts, "?");
   # split the request into project and version
   # eliminate extraneous updates.drupal.org if it exits.
   gsub(/\/updates.drupal.org/,"",urlparts[1]);

   gsub(/release-history\/\//,"release-history/",urlparts[1]);
   split(urlparts[1], urlfields, "/");
   project_name = urlfields[3];
   api_version = urlfields[4];
   split(urlparts[2],qsvars,"&");
   split(qsvars[1], site_query, "=");
   site_key = site_query[2];
   split(qsvars[2], version_query, "=");
# Convert contrib dev releases to dev releases, not full releases.
    gsub(/\.[0-9].*%2B[0-9]+-dev$/,".x-dev", version_query[2]);
 # Convert core dev releases to dev release.
    if (project_name == "drupal") {
      gsub(/\.[0-9]+-dev$/,".x-dev", version_query[2]);
    }
    gsub(/ /,"",version_query[2]);
    project_version = version_query[2];
    if (length(project_version) == 0) {
         next;
       }


# list variable is submodules in use for each project.
   split(qsvars[3], list_query, "=");
   gsub(/%2C/, "|", list_query[2]);
   # Occasionally we see actual commas instead of urlencoded ones:
   # 2018-11-30T15:09:56Z cache-fra19136 fastlyupdates[41062]: 212.108.235.187 | "-" | "-" | 2018-11-30 | 15:09:56 +0000 | GET /release-history/hierarchical_select/7.x?site_key=GhtEGmHu2lH_orR9i0wWAmZJcTieJqhfns7sxT8M698&version=7.x-3.0-beta2&list=hierarchical_select,hs_flatlist,hs_menu,hs_smallhierarchy,hs_taxonomy,hs_taxonomy_views | 200 | (null) | Drupal (+http://drupal.org/)
   gsub(/,/, "|", list_query[2]);
   gsub(/ /, "", list_query[2]);


   #sometimes we do not get a site key
   if (length(site_key) < 16) {
     next;
   }
   split(site_key,chars,"");
}

{
  d8_version="";
  guzzle_version="";
  curl_version="";
  php_version="";
}

# The user agent should contain php, curl, guzzle, and drupal version for d8 sites.
api_version == "8.x" && $9 ~ /curl/ && $9 ~ /Drupal/ {
  split($9,telemetry,/ /);
  gsub(/Drupal\//,"",telemetry[2]);
  gsub(/GuzzleHttp\//,"",telemetry[4]);
  gsub(/curl\//,"",telemetry[5]);
  gsub(/PHP\//,"",telemetry[6]);
  d8_version=telemetry[2];
  guzzle_version=telemetry[4];
  curl_version=telemetry[5];
  php_version=telemetry[6];
}

# But sometimes there isnt a curl entry.
api_version == "8.x" && $9 !~ /curl/ && $9 ~ /Drupal/ {
  split($9,telemetry,/ /);
  gsub(/Drupal\//,"",telemetry[2]);
  gsub(/GuzzleHttp\//,"",telemetry[4]);
  gsub(/PHP\//,"",telemetry[5]);

  d8_version=telemetry[2];
  guzzle_version=telemetry[4];
  php_version=telemetry[5];
}

# And sometimes there isnt a Drupal entry but there is a curl entry.
api_version == "8.x" && $9 ~ /curl/ && $9 !~ /Drupal/ {
  split($9,telemetry,/ /);
  gsub(/GuzzleHttp\//,"",telemetry[2]);
  gsub(/curl\//,"",telemetry[3]);
  gsub(/PHP\//,"",telemetry[4]);

  guzzle_version=telemetry[2];
  curl_version=telemetry[3];
  php_version=telemetry[4];
}


{
   split(php_version,phpstuff,/-/);

   print entry_timestamp","parts[4]","site_key >> ("/data/stats/updatestats/splits/" LOGFILENAME "/hosts/" SLOT ":" octets[1] "+" LOGFILENAME );

   print entry_timestamp","site_key","api_version","project_name","project_version","list_query[2]","d8_version","guzzle_version","curl_version","phpstuff[1]","phpstuff[2] >> ("/data/stats/updatestats/splits/" LOGFILENAME "/sites/" SLOT ":" toupper(chars[1]) toupper(chars[2]) "+" LOGFILENAME );

}


