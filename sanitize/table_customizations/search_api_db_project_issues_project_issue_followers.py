import table_customizations

class Search_Api_Db_Project_Issues_Project_Issue_Followers(table_customizations.TableHandler):

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
            INNER JOIN (
              SELECT *
              FROM {source}.node
              WHERE (node.type = 'forum' AND node.nid IN (SELECT nid FROM {source}.comment) AND node.created >= (unix_timestamp() - 60*24*60*60))
              OR (node.type = 'project_issue' AND node.created >= (unix_timestamp() - 60*24*60*60))
              OR (node.type NOT IN ('project_issue','forum'))
              AND node.uid IN (SELECT uid FROM {source}.users WHERE status = 1 OR uid = 0 OR name = 'bacon')
            ) AS node_mod
              ON node_mod.nid = {source}.{table}.item_id {limit}
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
