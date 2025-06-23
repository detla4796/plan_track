import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;

  const TaskTile({super.key, required this.task, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: onComplete,
        child: Icon(task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank, color: task.isCompleted ? Colors.green : Colors.grey),
      ),
      title: Text(task.title),
      subtitle: task.description != null ? Text(task.description!) : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (task.date.year > 1970)
            Text(
              "${task.date.day}.${task.date.month}.${task.date.year}",
              style: TextStyle(fontSize: 12),
            ),
          if (task.date.hour != 0 || task.date.minute != 0)
            Text(
              "${task.date.hour.toString().padLeft(2, '0')}:${task.date.minute.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
