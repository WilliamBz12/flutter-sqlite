import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite_offline/data/services/local_database_service.dart';

void main() {
  late LocalDatabaseService service;

  setUp(
    () async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      service = LocalDatabaseService();
      await service.init();
    },
  );

  test(
    'should database be initialized',
    () {
      expect(service.database?.isOpen, equals(true));
    },
  );
}
