import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/task_tile.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import '../services/auth_service.dart';
import '../screens/edit_task_screen.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  bool isLoading = true;
  String _searchQuery = '';
  int _dateSortState = 0;
  int _timeSortState = 0;
  int _titleSortState = 0;
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadTasks();
  }

  Future<void> loadUser() async {
    final auth = AuthService();
    final name = await auth.getUserName();
    final email = await auth.getUserEmail();
    setState(() {
      userName = name ?? 'Unknown';
      userEmail = email ?? 'email@example.com';
    });
  }

  Future<void> loadTasks() async {
    final apiService = ApiService();
    final loadedTasks = await apiService.getAllTasks();
    setState(() {
      tasks = loadedTasks;
      isLoading = false;
    });
  }

  void navigateToAddTask() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen()),
    );
    if (added == true) {
      loadTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Задача добавлена')),
      );
    }
  }

  Future<void> confirmDeleteTask(Task task) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Завершить и удалить задачу?', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Да'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Нет'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await deleteTask(task);
      loadTasks();
    }
  }

  Future<void> deleteTask(Task task) async {
    final apiService = ApiService();
    await apiService.deleteTask(task.id);
    await NotificationService.cancelAllTaskNotifications(task);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Задача удалена')),
    );
  }

  void handleTaskComplete(Task task) async {
    final apiService = ApiService();
    if (!task.isCompleted) {
      await apiService.updateTaskStatus(task.id, true);
      await NotificationService.cancelAllTaskNotifications(task);
      loadTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Задача завершена')),
      );
    } else {
      confirmDeleteTask(task);
    }
  }

  void _editTask(Task task) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTaskScreen(task: task)),
    );
    if (updated == true) {
      loadTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Задача обновлена')),
      );
    }
  }

  Future<void> confirmDeleteAllTasks() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить все задачи?'),
        content: Text('Это действие нельзя отменить. Вы уверены?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Нет'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Да, удалить'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final apiService = ApiService();
      for (final task in tasks) {
        await NotificationService.cancelAllTaskNotifications(task);
      }
      await apiService.deleteAllTasks();
      loadTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Все задачи удалены')),
      );
    }
  }

  Widget _buildSortIcon(IconData icon, int state) {
    if (state == 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blue),
          Icon(Icons.arrow_upward, size: 14, color: Colors.blue),
        ],
      );
    } else if (state == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.red),
          Icon(Icons.arrow_downward, size: 14, color: Colors.red),
        ],
      );
    }
    return Icon(icon, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = tasks.where((task) {
      if (_searchQuery.isNotEmpty && !task.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    if (_dateSortState == 1) {
      filteredTasks.sort((a, b) => a.date.compareTo(b.date));
    } else if (_dateSortState == 2) {
      filteredTasks.sort((a, b) => b.date.compareTo(a.date));
    }

    if (_timeSortState == 1) {
      filteredTasks.sort((a, b) => a.date.hour * 60 + a.date.minute - (b.date.hour * 60 + b.date.minute));
    } else if (_timeSortState == 2) {
      filteredTasks.sort((a, b) => b.date.hour * 60 + b.date.minute - (a.date.hour * 60 + a.date.minute));
    }

    if (_titleSortState == 1) {
      filteredTasks.sort((a, b) => a.title.compareTo(b.title));
    } else if (_titleSortState == 2) {
      filteredTasks.sort((a, b) => b.title.compareTo(a.title));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Ваши задачи'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName ?? 'Unknown'),
              accountEmail: Text(userEmail ?? 'email@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Настройки'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Календарь задач'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/calendar');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Выйти'),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? Center(child: Text('Нет задач.'))
              : Column( 
                children: [ 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: _buildSortIcon(Icons.date_range, _dateSortState),
                        onPressed: () {
                          setState(() {
                            _dateSortState = (_dateSortState + 1) % 3;
                          });
                        },
                        tooltip: 'Фильтр по дате',
                      ),
                      IconButton(
                        icon: _buildSortIcon(Icons.access_time, _timeSortState),
                        onPressed: () {
                          setState(() {
                            _timeSortState = (_timeSortState + 1) % 3;
                          });
                        },
                        tooltip: 'Фильтр по времени',
                      ),
                      IconButton(
                        icon: _buildSortIcon(Icons.sort_by_alpha,_titleSortState),
                        onPressed: () {
                          setState(() {
                            _titleSortState = (_titleSortState + 1) % 3;
                          });
                        },
                        tooltip: 'Фильтр по названию',
                      ),
                      IconButton(
                        icon: Icon(Icons.clear_all, color: Colors.orange),
                        tooltip: 'Сбросить фильтры',
                        onPressed: () {
                          setState(() {
                            _dateSortState = 0;
                            _timeSortState = 0;
                            _titleSortState = 0;
                            _searchQuery = '';
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          final result = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              String temp = _searchQuery;
                              return AlertDialog(
                                title: Text('Поиск по названию'),
                                content: TextField(
                                  autofocus: true,
                                  decoration: InputDecoration(hintText: 'Введите название'),
                                  onChanged: (v) => temp = v,
                                  controller: TextEditingController(text: _searchQuery),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, null),
                                    child: Text('Отмена'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, temp),
                                    child: Text('Поиск'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (result != null) {
                            setState(() {
                              _searchQuery = result;
                            });
                          }
                        },
                        tooltip: 'Поиск',
                      ),
                    ],
                  ),
                  Expanded(
                    child: filteredTasks.isEmpty
                        ? Center(child: Text('Нет задач по выбранным фильтрам'))
                        : ListView.builder(
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () => _editTask(filteredTasks[index]),
                              child: TaskTile(
                                task: filteredTasks[index],
                                onComplete: () => handleTaskComplete(filteredTasks[index]),
                              ),
                            ),
                          ),
                  ),
                ]
              ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 32, bottom: 16),
              child: FloatingActionButton(
                heroTag: 'deleteAll',
                backgroundColor: Colors.red,
                onPressed: confirmDeleteAllTasks,
                tooltip: 'Удалить все задачи',
                child: Icon(Icons.delete),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(right: 5, bottom: 16),
              child: FloatingActionButton(
                heroTag: 'addTask',
                onPressed: navigateToAddTask,
                tooltip: 'Добавить задачу',
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
