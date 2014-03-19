#!/usr/bin/env python
# encoding=UTF-8

"""Sample MySQL script. To run this script, install MySQL Python extension.
If you run Ubuntu type 'sudo apt-get install mysql-python'. You can find
a short introduction to Python MySQL module in Paul Dubois' article at
http://www.kitebird.com/articles/pydbapi.html."""

import MySQLdb

HOSTNAME = 'localhost'
USERNAME = 'test'
PASSWORD = 'test'
DATABASE = 'test'

def run_query(query):
    """Run a given query and return result as a tuple of tuples."""
    cursor = None
    connection = None
    try:
        connection = MySQLdb.connect(host = HOSTNAME,
                                     user = USERNAME,
                                     passwd = PASSWORD,
                                     db = DATABASE)
        cursor = connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute(query)
        connection.commit()
        return cursor.fetchall()
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.rollback()
            connection.close()

def main():
    """Main function."""
    result = run_query('SHOW DATABASES')
    for line in result:
        print line

if __name__ == '__main__':
    main()

