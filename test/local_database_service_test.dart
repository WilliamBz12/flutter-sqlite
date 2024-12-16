import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite_offline/data/services/local_database_service.dart';

void main() {
  late LocalDatabaseService databaseService;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    databaseService = LocalDatabaseService();
    await databaseService.init(inMemory: true); // Banco em memória
  });

  tearDown(() async {
    await databaseService.database.close();
  });

  test('Banco inicializa corretamente com inMemoryDatabasePath', () async {
    expect(databaseService.database.isOpen, true);
  });
}
