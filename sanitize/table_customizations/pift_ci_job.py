import table_customizations

class Pift_Ci_Job_Result(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns, srccolumns = self.field_handler.column_handler(column_names, self.table)
        query = """
          INSERT INTO {dest}.{table} ({columns})
          SELECT {srccolumns}
          FROM {source}.{table}
          """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        if self.dataset == 'skeleton':
            query = """
              INSERT INTO {dest}.{table} ({columns})
              SELECT {srccolumns}
              FROM {source}.{table}
              INNER JOIN {source}.pift_ci_job ON {source}.pift_ci_job.job_id = {source}.{table}.job_id
              AND {source}.pift_ci_job.created >= (unix_timestamp() - 30*24*60*60)
            """.format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        return query
