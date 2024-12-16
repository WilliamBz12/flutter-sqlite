import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/models/task/task.dart';

class LocalDatabaseService {
  late final Database _database;

  Future<void> init() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'tasks.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            isCompleted INTEGER DEFAULT 0,
            category TEXT
          )
        ''');
        print('Tabela criada: tasks');
      },
    );
  }

  Database get database => _database;

  Future<int> addTask(Task task) async {
    final id = await _database.insert('tasks', task.toMap());
    print('Tarefa adicionada: $id');
    return id;
  }
}
