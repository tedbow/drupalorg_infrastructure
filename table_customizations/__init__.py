"""@init docstring
On Bakery slave sites, the init column is almost a URI. It should match the master site's TLD
"""

import importlib

class TableHandler(object):
    def __init__(self, table, src, dst):
        self.table = table
        self.src = src
        self.dst = dst
        self.limit = 'LIMIT 1000'
        self.dataset = None

    def get_sql(self, column_names):
        columns = (', ').join([e[1] for e in column_names if not e[0]])
        print "Special tables {0} reached the plain insert.".format([e[1] for e in column_names if e[0]])
        query = """
          INSERT INTO 
            `{dest}`.`{table}` ({columns}) 
          SELECT 
            {columns} 
          FROM 
            `{source}`.`{table}` {limit}
          """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, limit=self.limit)
        return query

def get_handler(table, src, dst):
    try:
        importlib.import_module('table_customizations.' + table)
        print globals()[table]
        handler = getattr(globals()[table], table.title())
        return handler(table, src, dst)
    except ImportError:
        return TableHandler(table, src, dst)
