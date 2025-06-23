import 'task.dart';

class WeekPlan {
  final DateTime startOfWeek;
  final List<Task> tasks;

  WeekPlan({
    required this.startOfWeek,
    required this.tasks,
  });

  List<Task> tasksForDay(DateTime day) {
    return tasks.where((task) =>
      task.date.year == day.year &&
      task.date.month == day.month &&
      task.date.day == day.day
    ).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'startOfWeek': startOfWeek.toIso8601String(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }

  factory WeekPlan.fromJson(Map<String, dynamic> json) {
    return WeekPlan(
      startOfWeek: DateTime.parse(json['startOfWeek']),
      tasks: (json['tasks'] as List).map((e) => Task.fromJson(e)).toList(),
    );
  }
}
