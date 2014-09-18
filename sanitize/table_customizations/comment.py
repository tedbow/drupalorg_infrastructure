import table_customizations

class Comment(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns, srccolumns = self.field_handler.column_handler(column_names, self.table)
        query = """
          INSERT INTO
            {dest}.{table} ({columns})
          SELECT
            {srccolumns}
          FROM
            {source}.{table} {limit}
          """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        if self.dataset == 'skeleton':
            query = """
              INSERT INTO
                {dest}.{table} ({columns})
              SELECT
                {srccolumns}
              FROM
                {source}.{table} t
              LEFT JOIN
                {source}.node n on t.nid = n.nid
              WHERE
                t.status = 1
              AND
                ((n.type IN ('project_issue','forum') AND n.created >= (unix_timestamp() - 60*24*60*60)) OR n.type NOT IN ('project_issue','forum'))
              {limit}
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
