import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:planning_and_skills_app_client/Services/task_service.dart';
import 'package:planning_and_skills_app_client/Widgets/greetings_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/homescreen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double completionRate = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
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
      final int userId = int.parse(decodedToken['nameid'].toString());

      List tasks = await TaskService.getUserTasks(userId);
      DateTime today = DateTime.now();
      List todayTasks = tasks.where((task) {
        return DateTime.parse(task['date']).day == today.day &&
            DateTime.parse(task['date']).month == today.month &&
            DateTime.parse(task['date']).year == today.year;
      }).toList();

      int checkedTasks =
          todayTasks.where((task) => task['isChecked'] == true).length;
      double percentage =
          todayTasks.isNotEmpty ? checkedTasks / todayTasks.length : 0.0;

      setState(() {
        completionRate = percentage;
      });
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  String getMotivationalMessage(double completionRate) {
    if (completionRate == 0) {
      return "Let's get started! Every journey begins with a single step.";
    } else if (completionRate > 0 && completionRate < 0.25) {
      return "Nice start! Keep the momentum going!";
    } else if (completionRate >= 0.25 && completionRate < 0.5) {
      return "You're making progress—stay focused and push forward!";
    } else if (completionRate >= 0.5 && completionRate < 0.75) {
      return "Halfway there! Keep up the great work!";
    } else if (completionRate >= 0.75 && completionRate < 1.0) {
      return "Almost done! Give it your final push!";
    } else if (completionRate == 1.0) {
      return "Fantastic work! You've completed all your tasks today!";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xfff1f2f6),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Column(
            children: [
              GreetingsBar(),
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Color(0xfff1f2f6),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.035),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: screenWidth * 0.03),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's progress",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  color: Color(0xff2A3143),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(top: screenWidth * 0.02),
                                child: Text(
                                  getMotivationalMessage(completionRate),
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      CircularPercentIndicator(
                        radius: 60.0,
                        lineWidth: 10.0,
                        percent: completionRate,
                        center: Text('${(completionRate * 100).toInt()}%'),
                        progressColor: Color(0xFFFF6F61),
                        backgroundColor: Colors.grey[300]!,
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
