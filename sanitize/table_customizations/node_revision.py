import table_customizations

class Node_Revision(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns, srccolumns = self.field_handler.column_handler(column_names, self.table)
        query = """
          INSERT INTO {dest}.{table} ({columns})
          SELECT {srccolumns}
          FROM {source}.{table}
          {limit}
          """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        if self.dataset == 'skeleton':
            query = """
              INSERT INTO {dest}.{table} ({columns})
              SELECT {srccolumns}
              FROM {source}.{table}
              INNER JOIN {source}.node ON {source}.node.nid = {source}.{table}.nid AND {source}.node.status = 1
                AND ({source}.node.type NOT IN ('project_issue','forum')
                  OR (
                    (({source}.node.type = 'forum' AND {source}.node.nid IN (SELECT nid FROM {source}.comment)) OR ({source}.node.type = 'project_issue'))
                    AND {source}.node.created >= (unix_timestamp() - 60*24*60*60)
                  ))
              WHERE {source}.{table}.timestamp >= (unix_timestamp() - 60*24*60*60) OR {source}.node.vid = {source}.{table}.vid
              {limit}
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
