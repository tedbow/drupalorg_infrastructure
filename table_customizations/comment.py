import table_customizations

class Comment(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns = (', ').join([e[1] for e in column_names if not e[0]])
        srccolumns = columns
        for column in [e[1] for e in column_names if e[0]]:
            if column == 'hostname':
                columns += ', ' + column
                srccolumns += ", '127.0.0.1'"
            elif column == 'mail':
                columns += ', ' + column
                srccolumns += ", CONCAT(name, '@sanitized.invalid')"
        query = "INSERT INTO `{dest}`.`{table}` ({columns}) SELECT {srccolumns} FROM `{source}`.`{table}` {limit}".format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        print query
        return query
