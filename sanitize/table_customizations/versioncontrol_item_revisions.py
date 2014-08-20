import table_customizations

class Versioncontrol_Item_Revisions(table_customizations.TableHandler):

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
              (
              SELECT
                *
              FROM
                {source}.versioncontrol_operations
              WHERE
                author_date >= (unix_timestamp() - 60*24*60*60)
              ) AS versioncontrol_operations_mod
            ON
              {source}.{table}.vc_op_id = versioncontrol_operations_mod.vc_op_id {limit}
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
