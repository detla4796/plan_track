import '../models/task.dart';
import 'auth_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final AuthService _authService = AuthService();
  static final List<Task> _mockTasks = [];

  Future<Task> addTask(Task task) async {
    final userId = await _authService.currentUserId;
    await Future.delayed(const Duration(milliseconds: 500));
    if (userId == null) throw Exception("Пользователь не авторизован");

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: task.title,
      description: task.description,
      date: task.date,
      isCompleted: task.isCompleted,
    );
    _mockTasks.add(newTask);
    await _saveTasks();
    return newTask;
  }

  Future<List<Task>> getAllTasks() async {
    final userId = await _authService.currentUserId;
    if (userId == null) throw Exception("Пользователь не авторизован");
    return _mockTasks.where((t) => t.userId == userId).toList();
  }

  Future<void> deleteTask(String taskId) async {
    await Future.delayed(Duration(milliseconds: 500));
    _mockTasks.removeWhere((task) => task.id == taskId);
    await _saveTasks();
  }

  Future<void> deleteAllTasks() async {
    _mockTasks.clear();
    await _saveTasks();
  }

  Future<void> updateTaskStatus(String id, bool isCompleted) async {
    final userId = await _authService.currentUserId;
    await Future.delayed(Duration(milliseconds: 300));
    if (userId == null) throw Exception("Пользователь не авторизован");
    final index = _mockTasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _mockTasks[index] = Task(
        id: _mockTasks[index].id,
        userId: _mockTasks[index].userId,
        title: _mockTasks[index].title,
        description: _mockTasks[index].description,
        date: _mockTasks[index].date,
        isCompleted: isCompleted,
      );
      await _saveTasks();
    }
  }
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _mockTasks.map((t) => t.toJson()).toList();
    await prefs.setString('tasks', jsonEncode(tasksJson));
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final List decoded = jsonDecode(tasksString);
      _mockTasks
        ..clear()
        ..addAll(decoded.map((e) => Task.fromJson(e)).toList());
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    final userId = await _authService.currentUserId;
    await Future.delayed(Duration(milliseconds: 300));
    if (userId == null) throw Exception("Пользователь не авторизован");
    final index = _mockTasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _mockTasks[index] = updatedTask;
      await _saveTasks();
    }
  }
}
