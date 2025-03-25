import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:planning_and_skills_app_client/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GreetingsBar extends StatefulWidget {
  const GreetingsBar({super.key});

  @override
  State<GreetingsBar> createState() => _GreetingsBarState();
}

class _GreetingsBarState extends State<GreetingsBar> {
  TimeOfDay currentTime = TimeOfDay.now();
  String greetingMessage = "";
  String userFirstName = "";
  String userLastName = "";

  @override
  void initState() {
    super.initState();
    setMessage();
    setUserName();
  }

  Future<void> setUserName() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("token");
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found.')),
        );
        return;
      }
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final String email = decodedToken['email'];

      Map<String, dynamic> user = await UserService.getUserByEmail(email);
      userFirstName = user['firstName'];
      userLastName = user['lastName'];
      debugPrint("User CREDS ${user['firstName']}");
    } catch (e) {
      debugPrint("ERROR HERE MISS ${e.toString()}");
    }
  }

  void setMessage() {
    int toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

    if (toMinutes(currentTime) >= toMinutes(TimeOfDay(hour: 5, minute: 0)) &&
        toMinutes(currentTime) <= toMinutes(TimeOfDay(hour: 12, minute: 0))) {
      greetingMessage = "Good morning,";
    } else if (toMinutes(currentTime) >=
            toMinutes(TimeOfDay(hour: 12, minute: 1)) &&
        toMinutes(currentTime) <= toMinutes(TimeOfDay(hour: 17, minute: 0))) {
      greetingMessage = "Good afternoon,";
    } else if (toMinutes(currentTime) >=
            toMinutes(TimeOfDay(hour: 17, minute: 1)) &&
        toMinutes(currentTime) <= toMinutes(TimeOfDay(hour: 20, minute: 0))) {
      greetingMessage = "Good evening,";
    } else {
      greetingMessage = "Good night,";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 75,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greetingMessage,
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            SizedBox(
              height: 0.5,
            ),
            Text(
              "$userFirstName $userLastName",
              style: TextStyle(
                fontSize: 22,
              ),
            )
          ],
        ),
      ),
    );
  }
}
