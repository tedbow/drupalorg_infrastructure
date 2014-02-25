import table_customizations

class Node(table_customizations.TableHandler):

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
              WHERE 
                ({table}.type = 'forum'
              AND 
                {table}.nid IN (SELECT nid FROM {source}.comment)
              AND 
                {table}.created >= (unix_timestamp() - 60*24*60*60))
              OR
                ({table}.type = 'project_issue'
              AND 
                {table}.created >= (unix_timestamp() - 60*24*60*60))
              OR
                ({table}.type 
              NOT IN 
                ('project_issue','forum')) {limit}
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
