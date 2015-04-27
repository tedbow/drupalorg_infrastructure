import table_customizations

class Field_Revision_Comment_Body(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns, srccolumns = self.field_handler.column_handler(column_names, self.table)
        query = """
          INSERT INTO {dest}.{table} ({columns})
          SELECT {srccolumns}
          FROM {source}.{table} {limit}
          """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        if self.dataset == 'skeleton':
            query = """
              INSERT INTO {dest}.{table} ({columns})
              SELECT {srccolumns}
              FROM {source}.{table}
              INNER JOIN {source}.comment c ON c.cid = {source}.{table}.entity_id AND c.status = 1
              INNER JOIN {source}.node n ON n.nid = c.cid AND n.status = 1
              WHERE {source}.n.type NOT IN ('project_issue','forum') OR {source}.n.created >= (unix_timestamp() - 60*24*60*60)
              {limit}
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
