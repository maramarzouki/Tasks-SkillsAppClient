import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ReminderService {
  static final String? ipAddress = dotenv.env['IP_ADDRESS'];
  static final String baseUrl = "http://$ipAddress:5256/api/reminder";

  static Future<dynamic> createReminder({
    required String title,
    required bool isActive,
    required DateTime reminderTime,
    required int userId,
  }) async {
    final url = Uri.parse('$baseUrl/createReminder');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'isActive': isActive,
        'reminderTime': reminderTime.toIso8601String(),
        'userId': userId,
      }),
    );
    print('Status: ${response.statusCode}, Body: ${response.body}');

    if (response.body == null ||
        response.body.isEmpty ||
        response.body == "null") {
      print("Response body is null or empty");
      return "";
    }

    final Map<dynamic, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print(data);
      return data['message'];
    } else {
      throw Exception(data['error'] ?? 'Unknown error occurred');
    }
  }

  static Future<List> getUserReminders(userId) async {
    try {
      var url = Uri.parse('$baseUrl/getUserReminders/$userId');
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

  static Future<String> toggleReminder(userId, reminderId, isActive) async {
    try {
      var url = Uri.parse('$baseUrl/toggleReminder/$reminderId/$userId');
      final response = await http.put(
        url,
        headers: {'content-type': 'application/json'},
        body: jsonEncode(isActive),
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("Response Body: ${response.body}");
        return data['message'];
      } else {
        print('Failed to toggle reminder ${response.body}');
        throw Exception('Failed to toggle reminder');
      }
    } catch (e) {
      debugPrint("TOGGLE ERROR ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<String> deleteReminder(reminderID) async {
    try {
      var url = Uri.parse('$baseUrl/deleteReminder/$reminderID');
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
