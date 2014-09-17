#!/bin/env python
from MySQLdb import *
from whitelists.base import whitelist
import password
import table_customizations
from optparse import OptionParser
import field_formatter
#from multiprocessing import Process, Queue, current_process, freeze_support
import multiprocessing
#import datetime
#from multiprocessing import Pool
#from multiprocessing.dummy import Pool as ThreadPool 
import random


parser = OptionParser()
parser.add_option('-d', '--dest-db', dest="destdb", help="The name of the database we insert into.")
parser.add_option('-s', '--src-db', dest="sourcedb", help="The name of the database we select from.")
parser.add_option('-p', '--data-profile', dest="dataset", help="Pick the data profile whitelist overlay. (boss, infra, redacted, or skeleton)")
(options, args) = parser.parse_args()
if options.dataset == 'boss':
    import whitelists.boss
    print "Like a boss."

if options.dataset == 'infra':
    import whitelists.infra
    print "Infrastructing madness!"

if options.dataset == 'redacted':
    import whitelists.skeleton
    print "redacting!!"

if options.dataset == 'skeleton':
    import whitelists.skeleton
    print "Skeleton attack!"


sourcedb = options.sourcedb
if not sourcedb:
    sourcedb = 'drupal_sanitize'
    print "Using default source {0}".format(sourcedb)
destdb = options.destdb
if not destdb:
    destdb = 'drupal_export'
    print "Using default destination {0}".format(destdb)

db = connect(host=password.host, user=password.user, passwd=password.password)
db1 = connect(host=password.host, user=password.user, passwd=password.password)
db2 = connect(host=password.host, user=password.user, passwd=password.password)
db3 = connect(host=password.host, user=password.user, passwd=password.password)
db4 = connect(host=password.host, user=password.user, passwd=password.password)
db5 = connect(host=password.host, user=password.user, passwd=password.password)
db6 = connect(host=password.host, user=password.user, passwd=password.password)
db7 = connect(host=password.host, user=password.user, passwd=password.password)
c = db.cursor()
c1 = db1.cursor()
c2 = db2.cursor()
c3 = db3.cursor()
c4 = db4.cursor()
c5 = db5.cursor()
c6 = db6.cursor()
c7 = db7.cursor()


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

    field_handler = field_formatter.Field_Handler()

    qq = multiprocessing.Queue()
    NUMBER_OF_PROCESSES = 6

    for i in range(NUMBER_OF_PROCESSES):
        multiprocessing.Process(target=qrun, args=(qq,i)).start()

    for table in whitelist.get_tables():
        column_names = whitelist.process(table)
        if not column_names:
            #skip data for this table
            continue
        handler = table_customizations.get_handler(table, sourcedb, destdb, field_handler)
        try:
            handler.dataset = options.dataset
        except AttributeError:
            pass
        query = handler.get_sql(column_names)
#        print query
        qq.put(query)

    # Stop all child processes
    for i in range(NUMBER_OF_PROCESSES):
        qq.put('STOP')

def qrun(qq, i):
    for q in iter(qq.get, 'STOP'):
      if i == 1:
          d1(q)
      elif i == 2:
          d2(q)
      elif i == 3:
          d3(q)
      elif i == 4:
          d4(q)
      elif i == 5:
          d5(q)
      elif i == 6:
          d6(q)
      elif i == 7:
          d7(q)
      else:
          d(q)
def d(q):
    c.execute(q)
    db.commit()
    c.fetchall()

def d1(q):
    c1.execute(q)
    db1.commit()
    c1.fetchall()

def d2(q):
    c2.execute(q)
    db2.commit()
    c2.fetchall()

def d3(q):
    c3.execute(q)
    db3.commit()
    c3.fetchall()

def d4(q):
    c4.execute(q)
    db4.commit()
    c4.fetchall()

def d5(q):
    c5.execute(q)
    db5.commit()
    c5.fetchall()

def d6(q):
    c6.execute(q)
    db6.commit()
    c6.fetchall()

def d7(q):
    c7.execute(q)
    db7.commit()
    c7.fetchall()

if __name__ == "__main__":
    multiprocessing.freeze_support()
    run()
    c.close()

