import table_customizations

class Node(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns, srccolumns = self.field_handler.column_handler(column_names, self.table)
        query = """
          INSERT INTO {dest}.{table} ({columns})
          SELECT {srccolumns}
          FROM {source}.{table}
          WHERE {source}.{table}.status = 1
          {limit}
          """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        if self.dataset == 'skeleton':
            query = """
              INSERT INTO {dest}.{table} ({columns})
              SELECT {srccolumns}
              FROM {source}.{table}
              WHERE {source}.{table}.status = 1 AND ({source}.{table}.type NOT IN ('project_issue','forum')
                OR (
                  (({source}.{table}.type = 'forum' AND {source}.{table}.nid IN (SELECT nid FROM {source}.comment)) OR ({source}.{table}.type = 'project_issue'))
                  AND {source}.{table}.created >= (unix_timestamp() - 60*24*60*60)
                ))
              {limit}
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
