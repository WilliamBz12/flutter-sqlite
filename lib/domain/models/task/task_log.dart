class TaskLog {
  final int? id;
  final int taskId;
  final String action;
  final String timestamp;

  TaskLog({
    this.id,
    required this.taskId,
    required this.action,
    required this.timestamp,
  });

  factory TaskLog.fromMap(Map<String, dynamic> map) {
    return TaskLog(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      action: map['action'] as String,
      timestamp: map['timestamp'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'action': action,
      'timestamp': timestamp,
    };
  }
}
