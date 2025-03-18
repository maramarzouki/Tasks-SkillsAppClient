import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TaskService {
  static final String? ipAddress = dotenv.env['IP_ADDRESS'];
  static final String baseUrl = "http://$ipAddress:5256/api/task";

  static Future<String> createTask({
    required String label,
    required String description,
    required int startTime,
    required int endTime,
    required DateTime date,
    required int complexity,
    required int priority,
    int? interval,
    // int? intervalUnit,
    int? duration,
    int? durationUnit,
    required bool isChecked,
    required int userId,
    required String taskColor,
  }) async {
    final url = Uri.parse('$baseUrl/createTask');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'label': label,
        'description': description,
        'startTime': startTime,
        'endTime': endTime,
        'date': date.toIso8601String(),
        'complexity': complexity,
        'priority': priority,
        'taskColor': taskColor,
        'interval': interval,
        // 'intervalUnit': intervalUnit,
        'duration': duration,
        'durationUnit': durationUnit,
        'isChecked': isChecked,
        'userId': userId,
      }),
    );
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'];
    } else {
      throw Exception(data['error'] ?? 'Unknown error occurred');
    }
  }

  static Future<List> getUserTasks(userId) async {
    try {
      var url = Uri.parse('$baseUrl/getUserTasks/$userId');
      final response = await http.get(url, headers: {
        'content-type': 'application/json',
      });

      if (response.statusCode == 200) {
        print("Response Body: ${response.body}");

        if (response.body == null ||
            response.body.isEmpty ||
            response.body == "null") {
          print("Response body is null or empty");
          return [];
        }

        final jsonResponse = jsonDecode(response.body);
        List<dynamic> data;
        if (jsonResponse is List) {
          data = jsonResponse;
        } else if (jsonResponse is Map) {
          // Extract the list from the 'message' key based on your backend response
          data = jsonResponse['message'] ?? [];
        } else {
          data = [];
        }

        return data;
      } else {
        print('There was an error fetching data');
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  static Future<String> checkTask(taskId, isChecked) async {
    try {
      var url = Uri.parse('$baseUrl/checkTask/$taskId');
      final response = await http.put(
        url,
        headers: {'content-type': 'application/json'},
        body: jsonEncode(isChecked),
      );
      if (response.statusCode == 200) {
        print("Response Body: ${response.body}");
        // The backend returns a simple message as a string.
        return response.body;
      } else {
        print('There was an error deleting the task');
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  static Future<String> deleteTask(taskId) async {
    try {
      var url = Uri.parse('$baseUrl/deleteTask/$taskId');
      final response = await http.delete(
        url,
        headers: {
          'content-type': 'application/json',
        },
      );
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("Response Body: ${response.body}");
        // The backend returns a simple message as a string.
        return data['message'];
      } else {
        print('There was an error deleting the task');
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }
}
