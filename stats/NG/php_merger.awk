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
        master_file = "/data/stats/updatestats/sitemodel/master/php/" components[1] "_php_table.csv";
        system("touch " master_file)
        while (getline < master_file)
                {
                    split($0,hostrec,",");
                    hashkey = hostrec[1]","hostrec[2];
                    firstseen = hostrec[6];
                    lastseen = hostrec[7];
                    seencount = hostrec[8];

                    firstseens[hashkey] = firstseen;
                    lastseens[hashkey] = lastseen;
                    seencounts[hashkey] = seencount;
                    recordages[hashkey] = lastseen - firstseen;
                    guzzle[hashkey] = hostrec[3]
                    curl[hashkey] = hostrec[4]
                    extra[hashkey] = hostrec[5]

                }
        close(master_file);
       }

  {

   hashkey = $1","$2;
   firstseen = $6;
   lastseen = $7;
   seencount = $8;

   {
     # If we've never seen this key before, its a new record
     if (firstseens[hashkey] == "") {
          firstseens[hashkey] = firstseen;
          lastseens[hashkey] = lastseen;
          seencounts[hashkey] = seencount;
          recordages[hashkey] = lastseen - firstseen;
          guzzle[hashkey] = $3
          curl[hashkey] = $4
          extra[hashkey] = $5
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
      print key, guzzle[key], curl[key], extra[key], firstseens[key],lastseens[key],seencounts[key], recordages[key] >> (master_file);
   }

 }
