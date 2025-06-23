import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description ?? '');
    _selectedDate = widget.task.date.year > 1970
        ? DateTime(widget.task.date.year, widget.task.date.month, widget.task.date.day)
        : null;
    _selectedTime = (widget.task.date.hour != 0 || widget.task.date.minute != 0)
        ? TimeOfDay(hour: widget.task.date.hour, minute: widget.task.date.minute)
        : null;
  }

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
    final updatedTask = Task(
      id: widget.task.id,
      userId: userId!,
      title: _titleController.text,
      description: _descController.text.isEmpty ? null : _descController.text,
      date: dateTime,
      isCompleted: widget.task.isCompleted,
    );
    final apiService = ApiService();
    await apiService.updateTask(updatedTask);
    await NotificationService.scheduleTaskNotifications(updatedTask);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
      initialTime: _selectedTime ?? now,
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
      appBar: AppBar(title: Text('Редактировать задачу')),
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
              child: Text('Сохранить изменения'),
            ),
          ],
        ),
      ),
    );
  }
}