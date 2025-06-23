class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime date;
  final bool isCompleted;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.date,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json, {String? id}) {
    return Task(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'is_completed': isCompleted,
    };
  }
}
