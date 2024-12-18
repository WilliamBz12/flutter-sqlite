import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      },
    );
  }
}
