import sqlite3
import os
from pathlib import Path
from os import path
from datetime import datetime
import re


class PathClass(object):

    def get_first_db_file(self, mainDir):
        try:
            dir = sorted(Path(mainDir).iterdir(), key=path.getatime)[0]
            print('Db Dir: ', dir)
            if path.isfile(dir):
                return dir
            else:
                file = next(path.join(dir, f) for f in os.listdir(dir)
                            if path.isfile(path.join(dir, f)))
                print('Db Filename: ', file)
                return file
        except IndexError as indexErr:
            print(indexErr)
            print('ERROR: There are no folders in this path.')
            return False
        except OSError as osErr:
            print(osErr)
            print('ERROR: The path cannot be found.')
            return False

    def get_all_files(self, dirPath):
        return os.listdir(dirPath)


class Connection(object):

    def __init__(self, dbName):
        try:
            print('Database: ', dbName)
            self.conn = sqlite3.connect(dbName)
            self.cursor = self.conn.cursor()
            self.cursor.execute('SELECT SQLITE_VERSION()')
            self.data = self.cursor.fetchone()
            print('SQLite version: %s' % self.data)
        except sqlite3.Error:
            print('ERROR: Unable to establish a connection.')
            return False

    def commit_db(self):
        if self.conn:
            self.conn.commit()

    def close_db(self):
        if self.conn:
            self.conn.close()
            print('Closed connection.')


class DBClass(object):

    def __init__(self, mainDir):
        dbFile = PathClass().get_first_db_file(mainDir)
        self.db = Connection(dbFile)

    def select_from(self, tableName):
        cursor = self.db.cursor.execute(
            'select * from {};'.format(tableName)
        )
        collums = list(map(lambda x: x[0], cursor.description))
        rows = list(map(lambda c: c, cursor.fetchall()))
        print(collums, rows)
        return rows

    def execute_schema(self, schemaName):
        print('Executing schema %s...' % schemaName)
        try:
            with open(schemaName, 'rt') as f:
                print('SCHEMA: %s' % f)
                schema = f.read()
                self.db.cursor.executescript(schema)
        except sqlite3.Error:
            print('WARNING: SCHEMA has already been executed.')
            return False
        print('SCHEMA successfully executed.')

    def execute_all_schemas(self, path):
        for file in PathClass().get_all_files(path):
            self.execute_schema('%s/%s' % (path, file))

    def insert_tresults_values(self, rows):
        try:
            for values in rows:
                ########## PRE COMMAND ##########
                preCommand = "insert into ReferenceDate (ref_date) values (datetime('now', 'localtime'));"
                print('Pre Command: ', preCommand)
                self.db.cursor.execute(preCommand)
                ########## PRE SELECT ##########
                preSelect = 'select id_ref_date from ReferenceDate order by id_ref_date desc limit 1;'
                print('Pre Select: ', preSelect)
                refDateIdx = str(self.db.cursor.execute(preSelect).fetchone())
                trnl = str.maketrans(dict.fromkeys("()"))
                print(str(values)[1:-1])
                ########## COMMAND ##########
                command = 'insert into Results (script_index, robot, iteration, agent, sequence, result_name, result, elapsed_time, start_time, end_time, id_ref_date) values ({}, {});'.format(
                    str(values)[1:-1], refDateIdx.translate(trnl).replace(',', ''))
                print('Command: ', command)
                self.db.cursor.execute(command)
                ########## COMMIT ##########
                self.db.commit_db()
                print('Data successfully inserted.')
        except sqlite3.Error as sqlErr:
            print(sqlErr)
            print('WARNING: Invalid insertion process.')
            return False


class GenerateDBFile(object):

    def __init__(self, filePath):
        dbFile = '%s_%s.db' % (
            filePath, DateTimeClass().get_current_month_year()
        )
        if path.exists(dbFile):
            print('File already exists!')
        else:
            print('Generating db file...')
            file = open(dbFile, 'w+')
            print('Db file was created.')
            file.close()


class DateTimeClass(object):

    def get_current_month_year(self):
        return datetime.today().strftime('%m_%Y')


if __name__ == '__main__':

    results = DBClass(
        '/home/npml/.local/lib/python3.8/site-packages/rfswarm_manager/results/'
    )
    rowsResult = results.select_from('Results')
    print('Closing RFSwarm Result Database...')
    results.db.close_db
    print('Opening Backup Results Database...')
    GenerateDBFile('/home/npml/Projetos/Python/SQLite/perf_project/db/backup')
    results = DBClass('/home/npml/Projetos/Python/SQLite/perf_project/db')
    results.execute_schema('sql/tables.sql')
    results.execute_schema('sql/indexes.sql')
    results.execute_all_schemas('sql/views')
    results.insert_tresults_values(rowsResult)
