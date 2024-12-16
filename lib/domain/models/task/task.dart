import 'task_log.dart';

class Task {
  final int? id;
  final String title;
  final String description;
  final String category;
  final bool isCompleted;
  final int priority;
  final List<TaskLog>? logs;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isCompleted,
    required this.priority,
    this.logs,
  });

  Map<String, Object?> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority,
    };
  }

  factory Task.fromMap(Map<String, Object?> map, List<TaskLog> logs) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      priority: map['priority'] as int,
      logs: logs,
    );
  }
}
