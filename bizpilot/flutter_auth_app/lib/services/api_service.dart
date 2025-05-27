import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // For emulator

  Future<List<Customer>> getCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    final response = await http.get(
      Uri.parse('$baseUrl/customers/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => Customer.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load customers: ${response.statusCode}');
    }
  }

  Future<bool> createCustomer({
    required String name,
    required String email,
    required String phone,
    required String company,
    required String notes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    final response = await http.post(
      Uri.parse('$baseUrl/customers/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'email': email,
        'phone': phone,
        'company': company,
        'notes': notes,
      }),
    );

    print('POST /customers response: ${response.statusCode}');
    print('Response body: ${response.body}');


    return response.statusCode == 201;
  }
  
  Future<Customer> getCustomerById(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access');

  final response = await http.get(
    Uri.parse('$baseUrl/customers/$id/'),
    headers: {
      'Authorization': 'Bearer $token',
      'content-type':'application/json'
    },
  );

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return Customer.fromJson(jsonData);
  } else {
    throw Exception('Failed to fetch customer');
  }
  }


  Future<void> updateCustomer(int id, Customer customer) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    final response = await http.put(
      Uri.parse('$baseUrl/customers/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(customer.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update customer');
    }
  }

Future<void> deleteCustomer(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access');

  final response = await http.delete(
    Uri.parse('$baseUrl/customers/$id/'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 204) {
    throw Exception('Failed to delete customer');
  }
}


Future<void> createTask(int customerId, String title, String desc, DateTime dueDate) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access');

  final response = await http.post(
    Uri.parse('$baseUrl/customers/$customerId/tasks/create/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'title': title,
      'description': desc,
      'due_date': dueDate.toIso8601String().substring(0, 10), // 'YYYY-MM-DD'
    }),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to create task');
  }
}

  Future<List<Map<String, dynamic>>> getTasksForCustomer(int customerId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    final response = await http.get(
      Uri.parse('$baseUrl/customers/$customerId/tasks/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('Tasks API Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
    try {
      List data = jsonDecode(response.body);
      return data.map<Map<String, dynamic>>((task) => Map<String, dynamic>.from(task)).toList();
    } catch (e) {
      print('Error parsing tasks: $e');
      throw Exception('Invalid task data');
    }
  } else {
    throw Exception('Failed to load tasks');
  }

}

  Future<void> markTaskComplete(int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    final response = await http.patch(
      Uri.parse('$baseUrl/tasks/$taskId/complete/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark task as complete');
    }
  }



}
