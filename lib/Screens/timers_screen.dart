import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:planning_and_skills_app_client/screens/timer_screen.dart';
import 'package:planning_and_skills_app_client/Widgets/task_widget.dart';
import 'package:planning_and_skills_app_client/services/task_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimersScreen extends StatefulWidget {
  static const routeName = '/timersscreen';
  const TimersScreen({super.key});

  @override
  State<TimersScreen> createState() => _TimersScreenState();
}

class _TimersScreenState extends State<TimersScreen> {
  List<dynamic> tasksList = [];
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

  Map<DateTime, List<dynamic>> get _groupedTasks {
    return _groupTasksByDate(tasksList);
  }

  Map<DateTime, List<dynamic>> _groupTasksByDate(List<dynamic> tasks) {
    Map<DateTime, List<dynamic>> data = {};
    for (var task in tasks) {
      DateTime date = DateTime.parse(task['date']);
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      if (data[normalizedDate] == null) {
        data[normalizedDate] = [];
      }
      data[normalizedDate]!.add(task);
    }
    data.forEach((key, tasksList) {
      tasksList.sort((a, b) {
        return (a['startTime'] as int).compareTo(b['startTime'] as int);
      });
    });
    return data;
  }

  @override
  void initState() {
    super.initState();
    getUserTasks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getUserTasks();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<dynamic> tasksForSelectedDay = _groupedTasks[_selectedDay] ?? [];

    return Scaffold(
      backgroundColor: Color(0xfff1f2f6),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Tasks",
            style: TextStyle(
              color: Color(0xff2A3143),
              fontWeight: FontWeight.bold,
            ),
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
                        String hexColor =
                            tasksForSelectedDay[index]['taskColor'];
                        DateTime startTime =
                            DateTime.fromMillisecondsSinceEpoch(
                                tasksForSelectedDay[index]['startTime']);
                        DateTime endTime = DateTime.fromMillisecondsSinceEpoch(
                            tasksForSelectedDay[index]['endTime']);
                        String formattedStartTime =
                            DateFormat('ha').format(startTime);
                        String formattedEndTime =
                            DateFormat('ha').format(endTime);
                        Duration taskDuration = endTime.difference(startTime);
                        int taskDurationInSeconds = taskDuration.inSeconds;
                        return Padding(
                          padding: EdgeInsets.all(screenWidth * 0.01),
                          child: TaskWidget(
                            task: tasksForSelectedDay[index],
                            // taskId: tasksForSelectedDay[index]['id'],
                            // title: tasksForSelectedDay[index]['label'],
                            // isCheckedState: tasksForSelectedDay[index]
                            //     ['isChecked'],
                            // taskColorIndicator: Color(
                            //     int.parse(hexColor.replaceFirst('#', '0xff'))),
                            // description: tasksForSelectedDay[index]
                            //     ['description'],
                            // startTime: formattedStartTime,
                            // endTime: formattedEndTime,
                            startTaskTimer: () {
                              Duration taskDuration =
                                  endTime.difference(startTime);
                              int taskDurationInSeconds =
                                  taskDuration.inSeconds;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TimerScreen(
                                      initialDuration: taskDurationInSeconds),
                                ),
                              );
                            },
                            onTaskDeleted: () {
                              getUserTasks();
                            },
                          ),
                        );
                      })
                  : Text("No tasks for today!",
                      style: TextStyle(color: Colors.grey)))
        ]),
      )),
    );
  }
}
