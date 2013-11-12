import table_customizations

class Variable(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns = (', ').join([e[1] for e in column_names if not e[0]])
        srccolumns = columns
        for column in [e[1] for e in column_names if e[0]]:
            columns += ', ' + column
            #Special function would go here
        query = "INSERT INTO `{dest}`.`{table}` ({columns}) SELECT {srccolumns} FROM `{source}`.`{table}` WHERE `name` NOT LIKE '%key%' {limit}".format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        print query
        return query
