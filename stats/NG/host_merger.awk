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
        master_file = "/data/stats/updatestats/sitemodel/master/host/" components[1] "_host_table.csv";
        system("touch " master_file)
        while (getline < master_file)
                {
                    split($0,hostrec,",");
                    hashkey = hostrec[1];
                    firstseen = hostrec[2];
                    lastseen = hostrec[3];
                    seencount = hostrec[4];

                    firstseens[hashkey] = firstseen;
                    lastseens[hashkey] = lastseen;
                    seencounts[hashkey] = seencount;
                    recordages[hashkey] = lastseen - firstseen;

                }
        close(master_file);

       }

  {

   hashkey = $1;
   firstseen = $2;
   lastseen = $3;
   seencount = $4;


   # a project_version_table record looks like this:
        # host, first seen, last seen, count
        # 69.195.124.99,1543450797,1543535056,375
   {
     # If we've never seen this key before, its a new record
     if (firstseens[hashkey] == "") {
          firstseens[hashkey] = firstseen;
          lastseens[hashkey] = lastseen;
          seencounts[hashkey] = seencount;
          recordages[hashkey] = lastseen - firstseen;
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
      print key, firstseens[key],lastseens[key],seencounts[key], recordages[key] >> (master_file);

   }

 }
