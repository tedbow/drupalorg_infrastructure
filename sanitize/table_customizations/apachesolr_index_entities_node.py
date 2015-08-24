import table_customizations

class Apachesolr_Index_Entities_Node(table_customizations.TableHandler):

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
              LEFT JOIN {source}.node ON {source}.node.nid = {source}.{table}.entity_id
              WHERE {source}.{table}.status = 1 AND ({source}.node.type NOT IN ('project_issue','forum') OR {source}.node.created >= (unix_timestamp() - 60*24*60*60))
              {limit}
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
