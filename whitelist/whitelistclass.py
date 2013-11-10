class Whitelist:
    def __init__(self):
        self.tabledata = dict()

    def add(self, table, columns):
        self.tabledata[table] = columns

    def known_columns(self, table):
        known_plain = list()
        columns = self.table(table)
        for column in columns:
            if column[0] == '_' and ':' in column:
                function, name = column.split(':', 1)
                known_plain.append(name)
            else:
                known_plain.append(column)
        return known_plain

    def process(self, table):
        known_columns = list()
        columns = self.tabledata[table]
        for column in columns:
            if column[0] == '_' and ':' in column:
                function, name = column.split(':', 1)
                function = function.lstrip('_')
                known_columns.append((function, name))
            else:
                known_columns.append((None, column))
        return known_columns

    def get_tables(self):
        return ['users', 'access']
        return [self.name_only(e) for e in self.tabledata.keys() if '_ignore:' not in e]

    def name_only(self, id):
        if id[0] == '_' and ':' in id:
            function, name = id.split(':', 1)
            return name
        return id

    def function_only(self, id):
        if id[0] == '_' and ':' in id:
            function, name = id.split(':', 1)
            function = function.lstrip('_')
            return function

    def table(self, table):
        known_tables = self.tabledata.keys()
        plain_tables = map(self.name_only, known_tables)
        mapped_tables = dict(zip(plain_tables, known_tables))
        if table in plain_tables:
            return self.tabledata[mapped_tables[table]]

        else:
            return False

