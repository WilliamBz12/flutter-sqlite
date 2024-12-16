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
    return await databaseService.deleteTask(id);
  }

  @override
  Future<List<Task>> getTasks({String? category, bool? isCompleted}) async {
    final data = await databaseService.getTasks(
      category: category,
      isCompleted: isCompleted,
    );
    return data;
  }

  @override
  Future<bool> updateTask(Task task) async {
    return await databaseService.updateTask(task);
  }
}
