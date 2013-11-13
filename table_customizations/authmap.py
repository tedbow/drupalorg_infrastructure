import table_customizations

class Authmap(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns = (', ').join([e[1] for e in column_names if not e[0]])
        srccolumns = columns
        for column in [e[1] for e in column_names if e[0]]:
            columns += ', ' + column
            srccolumns += ", CONCAT(aid, '@sanitized.invalid')"
        query = """
          INSERT INTO 
            `{dest}`.`{table}` ({columns}) 
          SELECT
            {srccolumns} 
          FROM 
            `{source}`.`{table}` {limit}
          """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
