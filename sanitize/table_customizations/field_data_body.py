import table_customizations

class Field_Data_Body(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns, srccolumns = self.field_handler.column_handler(column_names, self.table)
        query = """
          INSERT INTO
            `{dest}`.`{table}` ({columns}) 
          SELECT 
            {srccolumns} 
          FROM
            `{source}`.`{table}`
          WHERE
            `bundle`
          NOT LIKE
            '%infra_page%' {limit}
          """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
