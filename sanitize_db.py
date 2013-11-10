#!/bin/env python
from MySQLdb import *
from whitelist import whitelist
import password
import table_customizations


sourcedb = 'drupal_sanitize'
destdb = 'drupal_2'

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
        handler = table_customizations.get_handler(table, sourcedb, destdb)
        query = handler.get_sql(column_names)
        c.execute(query)
        c.fetchall()



if __name__ == "__main__":
    run()
    c.execute('COMMIT')
    c.close()
