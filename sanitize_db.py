from MySQLdb import *
import whitelist, password

def generate_base_whitelist():
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

sourcedb = 'drupal_sanitize'
destdb = 'drupal_2'

db=connect(user=password.user, passwd=password.password)
c = db.cursor()

c.execute('DROP DATABASE IF EXISTS `{0}`'.format(destdb))
c.execute('CREATE DATABASE `{0}`'.format(destdb))

c.execute('SHOW TABLES IN `{0}`'.format(sourcedb))
tables = [e[0] for e in c.fetchall()]
for table in tables:
    query = "CREATE TABLE `{dest}`.`{table}` LIKE `{source}`.`{table}`".format(table=table, dest=destdb, source=sourcedb)
#    c.execute(query)
    generate_base_whitelist()
    continue
    query = "DESCRIBE `{source}`.`{table}`".format(table=table, source=sourcedb)
    c.execute(query)
    column_names = [e[0] for e in c.fetchall()]
    columns = (', ').join(column_names)
    query = "INSERT INTO `{dest}`.`{table}` ({columns}) SELECT {columns} FROM `{source}`.`{table}` LIMIT 100".format(table=table, dest=destdb, source=sourcedb, columns=columns)
    c.execute(query)




