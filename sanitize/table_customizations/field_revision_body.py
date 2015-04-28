import table_customizations

class Field_Revision_Body(table_customizations.TableHandler):

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
            INNER JOIN {source}.node ON {source}.node.nid = {source}.{table}.entity_id AND {source}.node.status = 1
              AND ({source}.node.type NOT IN ('project_issue','forum')
                OR (
                  (({source}.node.type = 'forum' AND {source}.node.nid IN (SELECT nid FROM {source}.comment)) OR ({source}.node.type = 'project_issue'))
                  AND {source}.node.created >= (unix_timestamp() - 60*24*60*60)
                ))
            INNER JOIN {source}.node_revision ON {source}.node_revision.vid = {source}.{table}.revision_id
              AND {source}.node_revision.timestamp >= (unix_timestamp() - 60*24*60*60) OR {source}.node.vid = {source}.node_revision.vid
            {limit}
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
