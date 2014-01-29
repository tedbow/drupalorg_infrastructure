"""@init docstring
On Bakery slave sites, the init column is almost a URI. It should match the master site's TLD
"""

import importlib

class TableHandler(object):
    def __init__(self, table, src, dst, field_handler):
        self.table = table
        self.src = src
        self.dst = dst
        self.limit = ''
        self.limit = 'LIMIT 1000'
        self.dataset = None
        self.field_handler = field_handler

    def get_sql(self, column_names):
        columns, srccolumns = self.field_handler.column_handler(column_names, self.table)
        query = """
          INSERT INTO 
            `{dest}`.`{table}` ({columns}) 
          SELECT 
            {srccolumns} 
          FROM 
            `{source}`.`{table}` {limit}
          """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query

def get_handler(table, src, dst, field_handler):
    try:
        importlib.import_module('table_customizations.' + table)
        #print globals()[table]
        handler = getattr(globals()[table], table.title())
        return handler(table, src, dst, field_handler)
    except ImportError:
        return TableHandler(table, src, dst, field_handler)
