#!/bin/gawk -f

# This script takes standard NCSA logs and reformats them into the same format that rsyslog creates.
{
  split($4,dateparts,"/");
  split(dateparts[3],timeparts,":");
  monthnum = sprintf("%02d",(match("JanFebMarAprMayJunJulAugSepOctNovDec",dateparts[2])+2)/3);
  node = substr(file,27,4);
  split(file,paths,"/");
  if (paths[6] == "drupal.org") paths[6] = "www.drupal.org";
  print timeparts[1] "-" monthnum "-" substr(dateparts[1],2) "T" timeparts[2] ":" timeparts[3] ":" timeparts[4] ".000000+00:00 " node " httpd-" paths[6] " " $0 | ("gzip >> /data/logs/www/httpd/" paths[6] "/" timeparts[1] "." monthnum "." substr(dateparts[1],2) ".httpd.gz"
);
}
