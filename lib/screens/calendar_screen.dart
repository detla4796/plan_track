import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/api_service.dart';
import '../models/task.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<Task>> _tasksByDate = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final apiService = ApiService();
    final tasks = await apiService.getAllTasks();
    final Map<DateTime, List<Task>> map = {};
    for (final task in tasks) {
      final date = DateTime(task.date.year, task.date.month, task.date.day);
      map.putIfAbsent(date, () => []).add(task);
    }
    setState(() {
      _tasksByDate = map;
    });
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _tasksByDate[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Календарь задач')),
      body: Column(
        children: [
          TableCalendar<Task>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getTasksForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: _getTasksForDay(_selectedDay ?? _focusedDay)
                  .map((task) => ListTile(
                        title: Text(task.title),
                        subtitle: task.description != null ? Text(task.description!) : null,
                        trailing: Icon(
                          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: task.isCompleted ? Colors.green : Colors.grey,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
