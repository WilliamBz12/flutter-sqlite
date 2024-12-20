import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_offline/domain/models/task/task.dart';

class LocalDatabaseService {
  static Database? _database;

  Future<void> init() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'tasks.db');

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        debugPrint("Banco de dados criado!");
        db.execute(""" CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            category TEXT,
            isCompleted INTEGER DEFAULT 0
            )""");
        debugPrint("TABELA DE TASKS CRIADA!");
      },
      onUpgrade: (db, oldVersion, newVersion) {
        print("new version: $newVersion");
      },
      onDowngrade: (db, oldVersion, newVersion) {
        print("newVersion: $newVersion");
      },
    );
  }

  Future<int?> createTask(Task task) async {
    final id = await _database?.insert(
      'tasks',
      task.toMap(),
    );
    debugPrint("task criada: $id");
    return id;
  }

  Future<List<Task>> getTasks({
    bool? isCompleted,
  }) async {
    List<String> where = [];
    List whereArgs = [];

    if (isCompleted != null) {
      where.add('isCompleted = ?');
      whereArgs.add(isCompleted ? 1 : 0);
    }

    final whereString = where.isNotEmpty ? where.join(' AND ') : null;

    final result = await _database?.query(
      'tasks',
      whereArgs: whereArgs,
      where: whereString,
    );
    final tasks = result?.map((e) => Task.fromMap(e)).toList();
    return tasks ?? [];
  }

  Future<int?> updateTask(Task task) async {
    final result = await _database?.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );

    return result;
  }

  Future<int?> deleteTask(int taskId) async {
    final result = await _database?.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );

    return result;
  }
}
