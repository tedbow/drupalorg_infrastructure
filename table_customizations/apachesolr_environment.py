import table_customizations

class Apachesolr_Environment(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns = (', ').join([e[1] for e in column_names if not e[0]])
        srccolumns = columns
        for column in [e[1] for e in column_names if e[0]]:
            columns += ', ' + column
            srccolumns += ", 'http://not.indexed.invalid'"
        query = "INSERT INTO `{dest}`.`{table}` ({columns}) SELECT {srccolumns} FROM `{source}`.`{table}` WHERE `name` NOT LIKE '%key%' LIMIT 100".format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns)
        print query
        return query
