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

  factory Task.fromMap(Map<String, dynamic> data) {
    return Task(
      title: data['title'],
      description: data['description'],
      category: data['category'],
      id: data['id'],
      isCompleted: data['isCompleted'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}
