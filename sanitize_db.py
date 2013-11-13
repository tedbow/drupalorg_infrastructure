#!/bin/env python
from MySQLdb import *
from whitelists.base import whitelist
import password
import table_customizations
from optparse import OptionParser



parser = OptionParser()
parser.add_option('-d', '--dest-db', dest="destdb", help="The name of the database we insert into.")
parser.add_option('-s', '--src-db', dest="sourcedb", help="The name of the database we select from.")
parser.add_option('-p', '--data-profile', dest="dataset", help="Pick the data profile whitelist overlay. (boss or skeleton)")
(options, args) = parser.parse_args()
if options.dataset == 'boss':
    import whitelists.boss
    print "Like a boss."

sourcedb = options.sourcedb
if not sourcedb:
    sourcedb = 'drupal_sanitize'
    print "Using default source {0}".format(sourcedb)
destdb = options.destdb
if not destdb:
    destdb = 'drupal_export'
    print "Using default destination {0}".format(destdb)

db=connect(user=password.user, passwd=password.password)
c = db.cursor()


def generate_base_whitelist(table):
    query = "DESCRIBE `{source}`.`{table}`".format(table=table, source=sourcedb)
    c.execute(query)
    column_names = [e[0] for e in c.fetchall()]
    columns2 = ('",\n        "').join(column_names)
    print """whitelist.add(
    table="{0}", 
    columns=[
        "{1}",
    ])
""".format(table, columns2)

def check_schema():
    c.execute('SHOW TABLES IN `{0}`'.format(sourcedb))
    tables = [e[0] for e in c.fetchall()]
    for table in tables:
        if whitelist.table("_ignore:" + table):
            print("Table '{table}' ignored".format(table=table))
            continue
        if whitelist.table("_nodata:" + table):
            print("Table '{table}' ignored".format(table=table))
            continue
        if not whitelist.table(table):
            print("Table '{table}' not presant in whitelist.py base config is:\n".format(table=table))
            generate_base_whitelist(table)
            continue
        query = "DESCRIBE `{source}`.`{table}`".format(table=table, source=sourcedb)
        c.execute(query)
        known_columns = whitelist.known_columns(table)
        unknown_columns = [e[0] for e in c.fetchall() if e[0] not in known_columns]
        if unknown_columns:
            print("Unknown column(s) {columns} found in table '{table}' fresh base config for whitelist.py is below. This needs to be merged with with current configuration.\n".format(columns=unknown_columns, table=table))
            generate_base_whitelist(table)

def run():
    c.execute('DROP DATABASE IF EXISTS `{0}`'.format(destdb))
    c.execute('CREATE DATABASE `{0}`'.format(destdb))
    check_schema()

    for table in whitelist.get_tables():
        query = "CREATE TABLE `{dest}`.`{table}` LIKE `{source}`.`{table}`".format(table=table, dest=destdb, source=sourcedb)
        print query
        c.execute(query)

    for table in whitelist.get_tables():
        column_names = whitelist.process(table)
        if not column_names:
            #skip data for this table
            continue
        handler = table_customizations.get_handler(table, sourcedb, destdb)
        try:
            handler.dataset = options.dataset
        except AttributeError:
            pass
        query = handler.get_sql(column_names)
        print query
        c.execute(query)
        c.fetchall()
    if options.dataset == 'skeleton':
        import whitelists.skeleton
        c.execute('COMMIT')
        c.execute('USE {0}'.format(destdb))
        for query in whitelists.skeleton.cleanup:
            print query
            c.execute(query)
            c.fetchall()




if __name__ == "__main__":
    run()
    c.execute('COMMIT')
    c.close()
