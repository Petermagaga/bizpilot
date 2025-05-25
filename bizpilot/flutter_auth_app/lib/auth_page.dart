import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:flutter_auth_app/screens/profile_screen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String message = '';

  Future<void> _login() async {
  final success = await _authService.login(
    _usernameController.text,
    _passwordController.text,
  );
  if (success) {
    // Navigate to ProfileScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  } else {
    setState(() {
      message = 'Login failed';
    });
  }
}

Future<void> _register() async {
  final success = await _authService.register(
    _usernameController.text,
    _passwordController.text,
  );
  if (success) {
    // Navigate to ProfileScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  } else {
    setState(() {
      message = 'Registration failed';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            ElevatedButton(onPressed: _register, child: const Text('Register')),
            const SizedBox(height: 10),
            Text(message),
          ],
        ),
      ),
    );
  }
}
