import table_customizations

class Multiple_Email(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns = (', ').join([e[1] for e in column_names if not e[0]])
        srccolumns = (', {0}.'.format(self.table)).join([e[1] for e in column_names if not e[0]])
        srccolumns = "{table}.{srccols}".format(table=self.table, srccols=srccolumns)
        for column in [e[1] for e in column_names if e[0]]:
            columns += ', ' + column
            srccolumns += ", CONCAT(`multiple_email`.`eid`, '.', `users`.`name`, '@sanitized.invalid')"
        query = """
          INSERT INTO
            `{dest}`.`{table}` ({columns}) 
          SELECT 
            {srccolumns} 
          FROM 
            `{source}`.`{table}` 
            LEFT JOIN 
              `{source}`.`users` 
            ON 
              (`multiple_email`.`uid` = `users`.`uid`)  {limit}
        """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
