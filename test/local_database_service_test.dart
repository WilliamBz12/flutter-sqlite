import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite_offline/data/services/local_database_service.dart';

void main() {
  late final LocalDatabaseService localDatabaseService;
  setUp(
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
}
