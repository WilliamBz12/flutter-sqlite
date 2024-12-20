import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_offline/domain/models/task/task.dart';

class LocalDatabaseService {
  static Database? _database;

  Database? get database => _database;

  Future<void> init() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'tasks.db');

    _database = await openDatabase(
      dbPath,
      version: 3,
      onCreate: (db, version) async {
        debugPrint("Banco de dados criado!");
        await db.execute(""" CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            category TEXT,
            isCompleted INTEGER DEFAULT 0
            )""");
        debugPrint("TABELA DE TASKS CRIADA!");
        migrations(db, version - 1);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        migrations(db, oldVersion);
        print("new version: $newVersion");
      },
      onDowngrade: (db, oldVersion, newVersion) {
        print("newVersion: $newVersion");
      },
    );
  }

  Future<void> migrations(Database db, int oldVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE tasks ADD COLUMN priority TEXT DEFAULT medio',
      );
      debugPrint("nova coluna adicionada");
    }

    if (oldVersion < 3) {
      await db.execute("""CREATE TABLE responsibles (
                    id INTEGER PRIMARY KEY AUTOINCREMENT, 
                    name TEXT NOT NULL
              )""");
      debugPrint("tabela de responsáveis criada");
      await db.execute(
        'ALTER TABLE tasks ADD COLUMN responsibleId INTEGER REFERENCES responsibles(id)',
      );
      debugPrint("Relacionamento de tabaleas adicionado");
    }
  }

  Future<int?> createTask(Task task) async {
    int? responsibleId;
    if (task.responsibleName != null) {
      final responsibles = await _database?.query(
        'responsibles',
        where: 'name LIKE ?',
        whereArgs: [task.responsibleName],
      );

      if (responsibles != null && responsibles.isNotEmpty) {
        responsibleId = responsibles.first['id'] as int;
      } else {
        responsibleId = await _database?.insert('responsibles', {
          'name': task.responsibleName,
        });
      }
    }
    final id = await _database?.insert(
      'tasks',
      task.toMap(responsibleId: responsibleId),
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

    final result = await _database?.rawQuery(
      """
    SELECT tasks.*, responsibles.name
    FROM tasks
    LEFT JOIN responsibles
    ON tasks.responsibleId = responsibles.id 
    ${whereString ?? ''}
""",
      whereArgs,
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
