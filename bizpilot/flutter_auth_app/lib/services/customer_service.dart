import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import  'package:flutter_auth_app/core/constants.dart'; // Make sure baseUrl is defined in config.dart

class CustomerService {
  Future<bool> createCustomer({
    required String name,
    required String email,
    String? phone,
    String? notes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString('access');

    final response = await http.post(
      Uri.parse('$baseUrl/customers/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $access',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone ?? '',
        'notes': notes ?? '',
      }),
    );

    return response.statusCode == 201;
  }
}
