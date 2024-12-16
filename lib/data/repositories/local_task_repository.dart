import 'package:sqlite_offline/data/repositories/task_repository.dart';
import 'package:sqlite_offline/data/services/local_database_service.dart';
import 'package:sqlite_offline/domain/models/task/task.dart';

class LocalTaskRepository implements TaskRepository {
  final LocalDatabaseService databaseService;

  LocalTaskRepository({required this.databaseService});

  @override
  Future<int> addTask(Task task) async {
    final id = databaseService.addTask(task);
    return id;
  }

  @override
  Future<bool> deleteTask(int id) async {
    return false;
  }

  @override
  Future<List<Task>> getTasks() async {
    final data = await databaseService.getTasks();
    return data;
  }

  @override
  Future<bool> updateTask(Task task) async {
    return true;
  }
}
