import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:planning_and_skills_app_client/models/task.dart';

class TaskService {
  static final String? ipAddress = dotenv.env['IP_ADDRESS'];
  static final String baseUrl = "http://$ipAddress:5256/api/task";

  static Future<String> createTask(Task task) async {
    final url = Uri.parse('$baseUrl/createTask');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'];
    } else {
      throw Exception(data['error'] ?? 'Unknown error occurred');
    }
  }

  static Future<List<Task>> getUserTasks(userId) async {
    try {
      var url = Uri.parse('$baseUrl/getUserTasks/$userId');
      final response = await http.get(url, headers: {
        'content-type': 'application/json',
      });

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        // Check if the response is a Map with a "message" key.
        if (decodedData is Map && decodedData.containsKey("message")) {
          final List tasksData = decodedData["message"];
          return tasksData.map((item) => Task.fromJson(item)).toList();
        } else if (decodedData is List) {
          // Fallback if the API returns a List directly.
          return decodedData.map((item) => Task.fromJson(item)).toList();
        } else {
          debugPrint("Unexpected response format: $decodedData");
          return [];
        }
      } else {
        debugPrint('Error fetching data. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
      return [];
    }
  }

  // static Future<List<Task>> getUserTasks(userId) async {
  //   try {
  //     var url = Uri.parse('$baseUrl/getUserTasks/$userId');
  //     final response = await http.get(url, headers: {
  //       'content-type': 'application/json',
  //     });

  //     if (response.statusCode == 200) {
  //       final dynamic decodedData = jsonDecode(response.body);

  //       // Ensure it's a List before mapping
  //       if (decodedData['message'] is List) {
  //         return decodedData.map((item) => Task.fromJson(item)).toList();
  //       } else {
  //         debugPrint("Unexpected response format: $decodedData");
  //         return [];
  //       }
  //       // debugPrint(
  //       //     "REPONSE Body ${(jsonDecode(response.body) as List).map((json) => Task.fromJson(json)).toList()}");
  //       // // return Task.fromJson(response.data);
  //       // return (jsonDecode(response.body) as List)
  //       //     .map((json) => Task.fromJson(json))
  //       //     .toList();
  //     } else {
  //       debugPrint('There was an error fetching data');
  //       return [];
  //     }
  //   } catch (e) {
  //     debugPrint("ERROROORORRR ${e.toString()}");
  //     return [];
  //   }
  // }

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
        debugPrint('There was an error checking the task');
        throw Exception('There was an error checking the task');
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
        debugPrint(data.toString());
        return 'There was an error deleting the task!';
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("EX HERE ${e.toString()}");
    }
  }
}
