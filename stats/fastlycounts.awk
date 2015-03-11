#!/bin/gawk -f

# Takes in fastly syslog entries and creates daily aggregate counts for download statistics
# A sample line looks like the following:
# 2015-03-11T21:45:39Z cache-ord1732 fastlyftp[39806]: 184.154.230.14 | "-" | "-" | 2015-03-11 | 21:45:39 +0000 | GET /files/projects/link-7.x-1.3.tar.gz | 200 | (null) | Drupal (+http://drupal.org/)

BEGIN {FS="|";} # Split line on pipes

 /files\/projects/ { # Only operate on lines with files/projects in them - ignore translations
   # split request line on spaces
   split($6,request," ");
   # Trim leading spaces from date field
   gsub(/^[ \t]+/,"",$4);
   # Trim trailing spaces from date field
   gsub(/[ \t]+$/,"",$4);
   # Split date components into individual y/m/d parts
   split($4,dateparts,"-");
   # pull out the filename, but trim off the initial slash
   filename=substr(request[2],2);
   # Keep a count of times we see Y-M-D-Filename (just in case the file contains multiple days)
   count[dateparts[1]","dateparts[2]","dateparts[3]","filename]++;
}

# At the end, loop through our count array and output Count,Y,M,D,Filename
END { for (i in count) print count[i] "," i}
