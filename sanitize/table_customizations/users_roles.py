import table_customizations

class Users_Roles(table_customizations.TableHandler):

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
        if self.dataset == 'skeleton':
            query = """
              INSERT INTO 
                `{dest}`.`{table}` ({columns}) 
              SELECT 
                {srccolumns} 
              FROM
                `{source}`.`{table}` 
                LEFT JOIN 
                  `{dest}`.`users` 
                ON 
                  (`{source}`.`{table}`.uid = `{dest}`.`users`.uid) 
                WHERE
                  `{dest}`.`users`.uid 
                IS NOT NULL 
                  {limit}
              """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
