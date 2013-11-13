Running the script
==================
./sanitize_db.py 
 
Options:
  -h, --help            show this help message and exit
  -d DESTDB, --dest-db=DESTDB
                        The name of the database we insert into.
  -s SOURCEDB, --src-db=SOURCEDB
                        The name of the database we select from.
  -p DATASET, --data-profile=DATASET
                        Pick the data profile whitelist overlay. (boss or
                        skeleton)


Setting up a new site
=====================

1. Copy the project into a new folder
2. Delete the whitelist file
3. Run the script to get the new schema
4. Put the new schema and put into a new whitelist file
5. Mark tables and columns with ignore and nodata tags
6. Run it and fix the errors in the table_config files
7. Create or update profiles if needed (boss, skeleton)
