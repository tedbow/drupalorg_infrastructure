import table_customizations

class Authmap(table_customizations.TableHandler):

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
