import table_customizations

class Simplenews_Subscriptions(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns = (', ').join([e[1] for e in column_names if not e[0]])
        srccolumns = columns
        for column in [e[1] for e in column_names if e[0]]:
            columns += ', ' + column
            srccolumns += ", CONCAT(snid, '@sanitized.invalid')"
        query = """
            INSERT INTO
              `{dest}`.`{table}` ({columns}) 
            SELECT 
              {srccolumns} 
            FROM
              `{source}`.`{table}` {limit}
          """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        print query
        return query
