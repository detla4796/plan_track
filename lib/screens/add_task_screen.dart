import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _submit() async {
    final userId = await AuthService().currentUserId;
    if (_titleController.text.isEmpty) return;

    final dateTime = _selectedDate == null
    ? DateTime(1970, 1, 1, _selectedTime?.hour ?? 0, _selectedTime?.minute ?? 0)
    : DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime?.hour ?? 0,
        _selectedTime?.minute ?? 0,
    );
    final task = Task(
      id: '',
      userId: userId!,
      title: _titleController.text,
      description: _descController.text.isEmpty ? null : _descController.text,
      date: dateTime,
    );
    final apiService = ApiService();
    final savedTask = await apiService.addTask(task);
    await NotificationService.scheduleTaskNotifications(savedTask);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
  final now = TimeOfDay.now();
  final picked = await showTimePicker(
    context: context,
    initialTime: now,
  );
  if (picked != null) {
    setState(() {
      _selectedTime = picked;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Новая задача')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Заголовок'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Описание (необязательно)'),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(_selectedDate == null
                      ? 'Дата не выбрана'
                      : 'Выбрано: ${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: Text('Выбрать дату'),
                ),
                Expanded(
                  child: Text(_selectedTime == null
                      ? 'Время не выбрано'
                      : 'Выбрано: ${_selectedTime!.hour}:${_selectedTime!.minute}'),
                ),
                TextButton(
                  onPressed: _pickTime,
                  child: Text('Выбрать время'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Добавить задачу'),
            ),
          ],
        ),
      ),
    );
  }
}
