import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_auth_app/core/constants.dart';

 

class AuthService {
  Future<bool> register(String username, String password) async {
    final url = Uri.parse('$baseUrl/register/');
    final res = await http.post(
      url,
      body: {'username': username, 'password': password},
    );

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      await _saveTokens(data['access'], data['refresh']);
      return true;
    }
    return false;
  }

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/token/');
    final res = await http.post(
      url,
      body: {'username': username, 'password': password},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _saveTokens(data['access'], data['refresh']);
      return true;
    }
    return false;
  }

  Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access', access);
    await prefs.setString('refresh', refresh);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access');
    await prefs.remove('refresh');
  }
}
