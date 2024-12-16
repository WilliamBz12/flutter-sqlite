import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_offline/domain/models/task/task_log.dart';

import '../../domain/models/task/task.dart';

class LocalDatabaseService {
  late final Database _database;

  Future<void> init({
    bool inMemory = false,
  }) async {
    final path = inMemory
        ? inMemoryDatabasePath
        : join(await getDatabasesPath(), 'tasks.db');

    _database = await openDatabase(
      path,
      version: 3,
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

        if (inMemory) {
          onUpgrade(db, version - 1, version);
        }
      },
      onUpgrade: onUpgrade,
    );
  }

  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion > 1) {
      await db
          .execute('ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 0');
      print('Coluna adicionada: priority');
    }
    if (newVersion > 2) {
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

    final List<Map<String, dynamic>> tasksMaps = await _database.query(
      'tasks',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    final List<Task> tasks = [];
    for (final taskMap in tasksMaps) {
      // Busca os logs associados à tarefa
      final List<Map<String, dynamic>> logsMaps = await _database.rawQuery(
        '''
      SELECT *
      FROM task_logs
      WHERE task_id = ?
      ORDER BY timestamp DESC
      ''',
        [taskMap['id']],
      );

      // Converte os mapas de logs para uma lista de objetos Log
      final logs = logsMaps.map((logMap) => TaskLog.fromMap(logMap)).toList();

      // Adiciona a tarefa com os logs à lista
      tasks.add(Task.fromMap(taskMap, logs));
    }

    return tasks;
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
