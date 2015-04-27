import table_customizations

class Field_Revision_Body(table_customizations.TableHandler):

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
              {source}.{table}
            INNER JOIN
              {source}.node_revision ON node_revision.vid = {table}.revision_id
            INNER JOIN
              {source}.node
            ON
              node.nid = node_revision.nid
            AND
              node.vid = node_revision.vid
            WHERE
              node_revision.timestamp >= (unix_timestamp() - 60*24*60*60)
            {limit}
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
