
class Field_Handler:
    def __init__(self):
        self.dataset = None

    def column_handler(self, columns, table=None):
        src_cols = ""
        dst_cols = ""
        for function, column in columns:
            dst_cols = "{dst_cols}, `{column}`".format(dst_cols=dst_cols, column=column)
            if function:
                mutator = getattr(self, function)
                mutated_src = mutator(column, table)
                src_cols = "{src_cols}, {mutated_src}".format(src_cols=src_cols, mutated_src=mutated_src)
            else:
                src_cols = "{src_cols}, `{table}`.`{column}`".format(src_cols=src_cols, column=column, table=table)
        return dst_cols.strip(','), src_cols.strip(',')


    def setenv(self, column, table):
        return "'http://not.indexed.invalid'"

    def sanitize_email(self, column, table):
        if table == 'authmap':
            return "CONCAT(`{table}`.`aid`, '@sanitized.invalid')".format(table=table)
        if table == 'multiple_email':
            return "CONCAT(`multiple_email`.`eid`, '.', `users`.`name`, '@sanitized.invalid')"
        if table == 'simplenews_subscriptions':
            return "CONCAT(`{table}`.`snid`, '@sanitized.invalid')".format(table=table)
        return "CONCAT(`{table}`.`name`, '@sanitized.invalid')".format(table=table)

    def sanitize_ip(self, column, table):
        return "'127.0.0.1'"
        
    def sanitize_text(self, column, table):
        if table == 'sshkey':
            return "'nobody@nomail.invalid'"
        return "'nope'"

    def sanitize_blank(self, column, table):
        return "''"

    def sanitize_timestamp(self, column, table):
        return '280299600'
