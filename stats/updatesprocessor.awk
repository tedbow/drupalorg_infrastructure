#!/bin/gawk -f

# This script takes standard NCSA logs and reformats them into the same format that rsyslog creates.
$7 ~ /updates.drupal.org/ {

  gsub(/http:\/\/updates.drupal.org\/80C301/,"",$7);
  gsub(/https:\/\/updates.drupal.org\/80C301/,"",$7);
  gsub(/"/,"",$6);
  gsub(/]/,"",$5);
  split($0, user_agent, "\"");
  if (user_agent[3] == "-") user_agent[3] = "(null)";


  split($7,parts,"/");
  split(parts[8],urlbits,"?");

  split($4,dateparts,"/");
  split(dateparts[3],timeparts,":");

  monthnum = sprintf("%02d",(match("JanFebMarAprMayJunJulAugSepOctNovDec",dateparts[2])+2)/3);
  mdy = timeparts[1] "-" monthnum "-" substr(dateparts[1],2);
  timestring = timeparts[2] ":" timeparts[3] ":" timeparts[4];

  print mdy "T" timestring "Z cache-fakepop fastlyupdates[000000]: " $1 " | \"" $2 "\" | \"" $3 "\" | " mdy " | " timestring " " $5 " | " $6 " " $7 " | " $9 " | " user_agent[3] " | " user_agent[5]
}
