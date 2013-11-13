import table_customizations

class Users_Access(table_customizations.TableHandler):

    def get_sql(self, column_names):
        columns = (', ').join(["`{table}`.{c}".format(c=e[1],table=self.table) for e in column_names if not e[0]])
        print "Special tables {0} reached the plain insert.".format([e[1] for e in column_names if e[0]])
        if self.dataset == 'skeleton':
           srccolumns = columns.replace('`users_access`.access', '280299600') 
        else:
            srccolumns = columns
        query = "INSERT INTO `{dest}`.`{table}` ({columns}) SELECT {srccolumns} FROM `{source}`.`{table}` {limit}".format(table=self.table, dest=self.dst, source=self.src, columns=columns, srccolumns=srccolumns, limit=self.limit)
        print query
        return query
