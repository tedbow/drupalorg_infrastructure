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
                   {dest}.{table} ( entity_type, bundle, deleted, entity_id, revision_id, language, delta, field_issue_changes_nid, field_issue_changes_vid, field_issue_changes_field_name, field_issue_changes_old_value, field_issue_changes_new_value)
                 SELECT
                    {table}.entity_type, {table}.bundle, {table}.deleted, {table}.entity_id, {table}.revision_id, {table}.language, {table}.delta, {table}.field_issue_changes_nid, {table}.field_issue_changes_vid, {table}.field_issue_changes_field_name, {table}.field_issue_changes_old_value, {table}.field_issue_changes_new_value
                 FROM
                   {source}.{table} 
                 INNER JOIN
                   {source}.field_data_field_issue_changes 
                 ON
                   {source}.field_data_field_issue_changes.entity_id = {source}.{table}.entity_id
                 LEFT JOIN
                   {source}.node n 
                 ON
                   n.nid = {source}.field_data_field_issue_changes.field_issue_changes_nid
                 AND
                   {source}.{table}.entity_type = {source}.field_data_field_issue_changes.entity_type
                 AND
                   {source}.{table}.revision_id = {source}.field_data_field_issue_changes.revision_id
                 AND
                   {source}.{table}.deleted = {source}.field_data_field_issue_changes.deleted
                 AND
                   {source}.{table}.delta = {source}.field_data_field_issue_changes.delta
                 AND
                   {source}.{table}.language = {source}.field_data_field_issue_changes.language
                 WHERE
                   n.type NOT IN ('project_issue','forum')
                 OR
                   n.created >= (unix_timestamp() - 60*24*60*60)
                 {limit}
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
