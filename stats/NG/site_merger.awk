#!/usr/bin/mawk -f

function basename(file, a, n) {
    n = split(file, a, "/")
    return a[n]
  }

 BEGIN {
        FS=",";
        OFS=",";

        processname = basename(ARGV[1]);
        split(processname,components,/\+/);
        master_file = "/data/stats/updatestats/sitemodel/master/site/" components[1] "_site_table.csv";
        system("touch " master_file)

        while (getline < master_file)
                {
                    split($0,hostrec,",");
                    hashkey = hostrec[1];
                    firstseen = hostrec[3];
                    lastseen = hostrec[4];
                    seencount = hostrec[5];

                    firstseens[hashkey] = firstseen;
                    lastseens[hashkey] = lastseen;
                    seencounts[hashkey] = seencount;
                    recordages[hashkey] = lastseen - firstseen;
                    maj_api[hashkey] = hostrec[2];

                }
        close(master_file);
       }

  {

   hashkey = $1;
   firstseen = $3;
   lastseen = $4;
   seencount = $5;

   {
     # If we've never seen this key before, its a new record
     if (firstseens[hashkey] == "") {
          firstseens[hashkey] = firstseen;
          lastseens[hashkey] = lastseen;
          seencounts[hashkey] = seencount;
          recordages[hashkey] = lastseen - firstseen;
          maj_api[hashkey] = $2;
          next;
     }
     # Otherwise we have a record, and need to update the counts and dates.
     if (firstseens[hashkey] > firstseen) {
       firstseens[hashkey] = firstseen;
     }
     if (lastseens[hashkey] < lastseen) {
            lastseens[hashkey] = lastseen;
     }
     seencounts[hashkey] += seencount;
     recordages[hashkey] = lastseens[hashkey] - firstseens[hashkey];
   }
 }

 END {
   system("rm -rf " master_file);
   for (key in firstseens) {
      print key, maj_api[key], firstseens[key],lastseens[key],seencounts[key], recordages[key] >> (master_file);
   }

 }