import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:planning_and_skills_app_client/Services/task_service.dart';
import 'package:planning_and_skills_app_client/Widgets/greetings_bar.dart';
import 'package:planning_and_skills_app_client/Widgets/task_widget.dart';
import 'package:planning_and_skills_app_client/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/homescreen';
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double completionRate = 0.0;
  List<Task> tasksList = [];
  int? userID;
  final DateTime _selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  Future<void> getUserTasks() async {
    print("getTasks called");
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
      tasksList = await TaskService.getUserTasks(userId);
      setState(() {});
      print("tasksListAAA: $tasksList");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Map<DateTime, List<Task>> get _groupedTasks {
    return _groupTasksByDate(tasksList);
  }

  Map<DateTime, List<Task>> _groupTasksByDate(List<Task> tasks) {
    Map<DateTime, List<Task>> data = {};
    for (var task in tasks) {
      DateTime date = task.date;
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      if (data[normalizedDate] == null) {
        data[normalizedDate] = [];
      }
      data[normalizedDate]!.add(task);
    }
    data.forEach((key, tasksList) {
      tasksList.sort((a, b) {
        return (a.startTime).compareTo(b.startTime);
      });
    });
    return data;
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   getUserTasks();
  // }

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

      List<Task> tasks = await TaskService.getUserTasks(userId);
      DateTime today = DateTime.now();
      List<Task> todayTasks = tasks.where((task) {
        return task.date.day == today.day &&
            task.date.month == today.month &&
            task.date.year == today.year;
      }).toList();

      int checkedTasks = todayTasks.where((task) => task.isChecked).length;
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
  void initState() {
    super.initState();
    getUserTasks();
    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<Task> tasksForSelectedDay = _groupedTasks[_selectedDay] ?? [];
    return Scaffold(
      backgroundColor: Color(0xfff1f2f6),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Text(
                'Today\'s tasks',
                style: TextStyle(
                    color: const Color(0xff2A3143),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Container(
                  child: tasksForSelectedDay.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: tasksForSelectedDay.length,
                          itemBuilder: (context, index) {
                            // String hexColor =
                            //     tasksForSelectedDay[index]['taskColor'];
                            // DateTime startTime =
                            //     DateTime.fromMillisecondsSinceEpoch(
                            //         tasksForSelectedDay[index]['startTime']);
                            // DateTime endTime =
                            //     DateTime.fromMillisecondsSinceEpoch(
                            //         tasksForSelectedDay[index]['endTime']);
                            // String formattedStartTime =
                            //     DateFormat('ha').format(startTime);
                            // String formattedEndTime =
                            //     DateFormat('ha').format(endTime);
                            // Duration taskDuration =
                            //     endTime.difference(startTime);
                            // int taskDurationInSeconds = taskDuration.inSeconds;
                            return Padding(
                              padding: EdgeInsets.all(screenWidth * 0.01),
                              child: TaskWidget(
                                task: tasksForSelectedDay[index],
                                // taskId: tasksForSelectedDay[index]['id'],
                                // title: tasksForSelectedDay[index]['label'],
                                // isCheckedState: tasksForSelectedDay[index]
                                //     ['isChecked'],
                                // taskColorIndicator: Color(int.parse(
                                //     hexColor.replaceFirst('#', '0xff'))),
                                // description: tasksForSelectedDay[index]
                                //     ['description'],
                                // startTime: formattedStartTime,
                                // endTime: formattedEndTime,
                                onTaskDeleted: () {
                                  getUserTasks();
                                },
                              ),
                            );
                          })
                      : Text("No tasks for today!",
                          style: TextStyle(color: Colors.grey)))
            ],
          ),
        ),
      ),
    );
  }
}
