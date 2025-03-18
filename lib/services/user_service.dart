import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:planning_and_skills_app_client/models/user.dart';

class UserService {
  static final String? ip_address = dotenv.env['IP_ADDRESS'];
  static String baseUrl = "http://$ip_address:5256/api/auth";

  static Future<String> register(User user) async {
    try {
      var url = Uri.parse('$baseUrl/register');
      final response = await http.post(
        url,
        headers: {'content-type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'];
      } else {
        throw Exception(data['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<String> login(User user) async {
    try {
      var url = Uri.parse('$baseUrl/login');
      final response = await http.post(url,
          headers: {'content-type': 'application/json'},
          body: jsonEncode(user.toJson()));
      if (response.body == null || response.body.isEmpty) {
        throw Exception("Empty response from server");
      }

      final Map<String, dynamic>? data = jsonDecode(response.body);

      if (data == null) {
        throw Exception("Failed to decode response data");
      }

      if (response.statusCode == 200) {
        if (data['msg'] == null) {
          throw Exception("Server response is missing token");
        }
        return data['msg'];
      } else {
        throw Exception(data['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<String> verifyEmailToResetPassword(String email) async {
    try {
      var url = Uri.parse('$baseUrl/sendCode');
      final response = await http.post(
        url,
        headers: {'content-type': 'application/json'},
        body: jsonEncode(email),
      );
      if (response.body == null || response.body.isEmpty) {
        throw Exception("Empty response from server");
      }

      final Map<String, dynamic>? data = jsonDecode(response.body);

      if (data == null) {
        throw Exception("Failed to decode response data");
      }

      if (response.statusCode == 200) {
        if (data['message'] == null) {
          throw Exception("Server response is missing token");
        }
        return data['message'];
      } else {
        print("ERRORRR $data");
        throw Exception(data['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<String> verifyCode(email, code) async {
    try {
      var url = Uri.parse('$baseUrl/verifyCode');
      final response = await http.post(
        url,
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'ChangePasswordCode': code,
        }),
      );
      if (response.body == null || response.body.isEmpty) {
        throw Exception("Empty response from server");
      }

      final Map<String, dynamic>? data = jsonDecode(response.body);

      if (data == null) {
        throw Exception("Failed to decode response data");
      }

      if (response.statusCode == 200) {
        if (data['message'] == null) {
          throw Exception("Server response is missing token");
        }
        return data['message'];
      } else {
        print("ERRORRR $data");
        throw Exception(data['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<String> resetPassword(email, password) async {
    try {
      var url = Uri.parse('$baseUrl/resetPassword');
      final response = await http.put(
        url,
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (response.body == null || response.body.isEmpty) {
        throw Exception("Empty response from server");
      }

      final Map<String, dynamic>? data = jsonDecode(response.body);

      if (data == null) {
        throw Exception("Failed to decode response data");
      }

      if (response.statusCode == 200) {
        if (data['message'] == null) {
          throw Exception("Server response is missing token");
        }
        print("responseeeeeeeeeee ${data['message']}");
        return data['message'];
      } else {
        print("ERRORRR $data");
        throw Exception(data['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> getUserByEmail(email) async {
    try {
      var url = Uri.parse('$baseUrl/getUserByEmail/$email');
      final response = await http.get(url, headers: {
        'content-type': 'application/json',
      });

      if (response.statusCode == 200) {
        debugPrint("Response Body: ${response.body}");

        if (response.body.isEmpty || response.body == "null") {
          debugPrint("Response body is null or empty");
          return "";
        }

        final jsonResponse = jsonDecode(response.body);

        Map<String, dynamic> data = jsonResponse['message'];
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
}
