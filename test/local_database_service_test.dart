import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite_offline/data/services/local_database_service.dart';
import 'package:sqlite_offline/domain/models/task/task.dart';

void main() {
  late final LocalDatabaseService localDatabaseService;
  setUpAll(
    () async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      localDatabaseService = LocalDatabaseService();
      await localDatabaseService.init(
        inMemoryDatabase: true,
      );
    },
  );
  test(
    'Banco de dados deve inicializar corretamente',
    () {
      expect(localDatabaseService.database?.isOpen, equals(true));
    },
  );

  test(
    'Deverá criar uma task na tabela',
    () async {
      final task = Task(
        title: 'Fazer dever de casa',
        description: '',
        category: 'atividades',
        isCompleted: false,
        priority: 'alta',
      );
      final result = await localDatabaseService.createTask(task);
      expect(result, isNot(equals(null)));
    },
  );

  test(
    'Deverá listar os itens salvos',
    () async {
      final task = Task(
        title: 'Lavar louça',
        description: '',
        category: 'casa',
        isCompleted: false,
        priority: 'alta',
      );
      await localDatabaseService.createTask(task);
      final result = await localDatabaseService.getTasks();
      expect(result.length, equals(2));
    },
  );
  test(
    'Deverá listar os itens completados',
    () async {
      final task = Task(
        title: 'Varrer a casa',
        description: '',
        category: 'casa',
        isCompleted: true,
        priority: 'alta',
      );
      await localDatabaseService.createTask(task);
      final result = await localDatabaseService.getTasks(isCompleted: true);
      expect(result.length, equals(1));
    },
  );
}
