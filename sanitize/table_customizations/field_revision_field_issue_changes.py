import table_customizations 

class Field_Revision_Field_Issue_Changes(table_customizations.TableHandler):

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
                {source}.field_data_field_issue_changes
              ON
                {source}.field_data_field_issue_changes.entity_id = {source}.{table}.entity_id
              AND
                {source}.{table}.entity_id = {source}.field_data_field_issue_changes.entity_id 
              AND
                {source}.{table}.entity_type = {source}.field_data_field_issue_changes.entity_type 
              AND
                {source}.{table}.revision_id = {source}.field_data_field_issue_changes.revision_id
              AND
                {source}.{table}.deleted = {source}.field_data_field_issue_changes.deleted
              AND
                {source}.{table}.delta = {source}.field_data_field_issue_changes.delta
              AND
                {source}.{table}.language = {source}.field_data_field_issue_changes.language {limit}
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
