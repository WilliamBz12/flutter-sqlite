import 'package:flutter/foundation.dart';

import '../../../data/repositories/task_repository.dart';
import '../../models/task/task.dart';

/// Use Case para obter todas as tarefas
class GetTasksUseCase {
  GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  Future<List<Task>> call() async {
    try {
      return await _repository.getTasks();
    } catch (e) {
      debugPrint('Erro ao buscar tarefas: $e');
      rethrow;
    }
  }
}
