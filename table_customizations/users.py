import table_customizations

class Users(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns = (', ').join([e[1] for e in column_names if not e[0]])
        srccolumns = columns
        for column in [e[1] for e in column_names if e[0]]:
            if column in ('mail', 'init'):
                columns += ', ' + column
                srccolumns += ", CONCAT(name, '@sanitized.invalid')"
            elif column == 'pass':
                columns += ', ' + column
                srccolumns += ", 'nope'"
            elif column == 'data':
                columns += ', ' + column
                srccolumns += ", ''"
        query = """
          INSERT INTO 
            `{dest}`.`{table}` ({columns}) 
          SELECT
            {srccolumns} 
          FROM 
            `{source}`.`{table}` {limit}
          """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        if self.dataset == 'skeleton':
            srccolumns = srccolumns.replace('access', '280299600')
            query = """
              INSERT INTO 
                `{dest}`.`{table}` ({columns}) 
              SELECT 
                {srccolumns} 
              FROM 
                `{source}`.`{table}` 
              WHERE 
                `{table}`.status = 1 
              AND 
                (`{table}`.uid = 0 
              OR 
                `{table}`.name = 'bacon') {limit}
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
