import 'package:flutter_sqlite_demo/models/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tasksTableName = 'tasks';
  final String _tasksIdColumnName = 'id';
  final String _tasksContentColumnName = 'content';
  final String _tasksStatusColumnName = 'status';

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'to_do.db');

    return await openDatabase(databasePath, version: 2,
        onCreate: (db, version) async {
      print("Creating tasks table");
      await db.execute('''
        CREATE TABLE $_tasksTableName (
          $_tasksIdColumnName INTEGER PRIMARY KEY,
          $_tasksContentColumnName TEXT NOT NULL,
          $_tasksStatusColumnName INTEGER NOT NULL
        )
      ''');
    });
  }

  Future<void> addTask(String content) async {
    final db = await database;
    await db.insert(_tasksTableName, {
      _tasksContentColumnName: content,
      _tasksStatusColumnName: 0,
    });
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(_tasksTableName);

    return data
        .map((e) => Task(
              id: e[_tasksIdColumnName] as int,
              status: e[_tasksStatusColumnName] as int,
              content: e[_tasksContentColumnName] as String,
            ))
        .toList();
  }

  Future<void> updateTaskStatus(int id, int status) async {
    final db = await database;

    await db.update(
      _tasksTableName,
      {
        _tasksStatusColumnName: status,
      },
      where: '$_tasksIdColumnName = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      _tasksTableName,
      where: '$_tasksIdColumnName = ?',
      whereArgs: [id],
    );
  }
}
