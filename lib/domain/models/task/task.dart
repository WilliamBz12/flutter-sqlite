class Task {
  final int? id;
  final String title;
  final String description;
  final String category;
  final bool isCompleted;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isCompleted,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
    );
  }
}
