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
      version: 2,
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
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 0');
          print('Coluna adicionada: priority');
        }
        if (oldVersion < 3) {
          await db.execute('''
      CREATE TABLE task_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY(task_id) REFERENCES tasks(id)
      )
    ''');
          print('Tabela criada: task_logs');
        }
        print('Atualizando banco da versão $oldVersion para $newVersion');
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        print('Revertendo banco da versão $oldVersion para $newVersion');
      },
    );
  }

  Database get database => _database;

  Future<int> addTask(Task task) async {
    final id = await _database.insert('tasks', task.toMap());
    print('Tarefa adicionada: $id');

    await _database.insert('task_logs', {
      'task_id': id,
      'action': 'Criação',
      'timestamp': DateTime.now().toIso8601String(),
    });
    return id;
  }

  Future<List<Task>> getTasks({String? category, bool? isCompleted}) async {
    final whereClauses = [];
    final whereArgs = [];

    if (category != null) {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    if (isCompleted != null) {
      whereClauses.add('isCompleted = ?');
      whereArgs.add(isCompleted ? 1 : 0);
    }

    final whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await _database.query(
      'tasks',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<bool> updateTask(Task task) async {
    await _database.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    print('Tarefa atualizada: ${task.title}');
    await _database.insert('task_logs', {
      'task_id': task.id,
      'action': 'Edição',
      'timestamp': DateTime.now().toIso8601String(),
    });
    return true;
  }

  Future<bool> deleteTask(int id) async {
    await _database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Tarefa excluída: $id');
    return true;
  }
}
