import 'package:flutter/material.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    themeNotifier.value = mode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: ListView(
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) => SwitchListTile(
              title: Text('Тёмная тема'),
              value: mode == ThemeMode.dark,
              onChanged: (bool value) {
                _setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          ListTile(
            title: Text('Синхронизация с календарём'),
            onTap: () {
              // TODO: реализовать синхронизацию
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Функция в разработке')),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('О приложении'),
            subtitle: Text('Версия 1.0.0'),
          ),
        ],
      ),
    );
  }
}
