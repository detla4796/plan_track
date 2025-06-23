import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen ({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _errorMessage;

  void _register() async {
    bool success = await _authService.register(
      _emailController.text,
      _passwordController.text,
      name: _usernameController.text,
    );

    if (success) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _errorMessage = 'Ошибка регистрации (email уже занят или поля пусты)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Регистрация')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _usernameController, decoration: InputDecoration(labelText: 'Имя пользователя')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Пароль'), obscureText: true),
            if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _register, child: Text('Зарегистрироваться')),
          ],
        ),
      ),
    );
  }
}
