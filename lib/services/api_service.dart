import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // בחירת כתובת השרת לפי הפלטפורמה
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    } catch (e) {
      // Platform.isAndroid might throw on web, but kIsWeb handles it
    }
    return 'http://localhost:3000/api'; // For Windows, iOS simulator, etc.
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Registration failed',
      );
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    String token,
    String name,
    String email,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Failed to update profile',
      );
    }
  }

  // --- Job Type Methods ---

  Future<List<dynamic>> getJobTypes(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/job-types'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load job types from server');
    }
  }

  Future<void> upsertJobType(
    String token,
    Map<String, dynamic> jobTypeData,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/job-types'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(jobTypeData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sync job type to server');
    }
  }

  Future<void> deleteJobType(String token, String jobTypeId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/job-types/$jobTypeId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete job type from server');
    }
  }

  // --- Shift Methods ---

  Future<List<dynamic>> getShifts(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/shifts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load shifts from server');
    }
  }

  Future<void> upsertShift(String token, Map<String, dynamic> shiftData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/shifts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(shiftData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sync shift to server');
    }
  }

  Future<void> deleteShift(String token, String shiftId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/shifts/$shiftId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete shift from server');
    }
  }

  // --- Expense Methods ---

  Future<List<dynamic>> getExpenses(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/expenses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load expenses from server');
    }
  }

  Future<void> upsertExpense(
    String token,
    Map<String, dynamic> expenseData,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/expenses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(expenseData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sync expense to server');
    }
  }

  Future<void> deleteExpense(String token, String expenseId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/expenses/$expenseId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete expense from server');
    }
  }
}
