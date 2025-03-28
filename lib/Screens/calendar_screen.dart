import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:planning_and_skills_app_client/Widgets/add_reminder_widget.dart';
import 'package:planning_and_skills_app_client/Widgets/calendar.dart';
import 'package:planning_and_skills_app_client/Widgets/calendar_tabs.dart';
import 'package:planning_and_skills_app_client/Widgets/create_task_form.dart';
import 'package:planning_and_skills_app_client/Widgets/greetings_bar.dart';
import 'package:planning_and_skills_app_client/Widgets/reminder_widget.dart';
import 'package:planning_and_skills_app_client/Widgets/task_board.dart';
import 'package:planning_and_skills_app_client/Widgets/task_widget.dart';
import 'package:planning_and_skills_app_client/models/task.dart';
import 'package:planning_and_skills_app_client/services/permission_handler.dart';
import 'package:planning_and_skills_app_client/services/reminder_service.dart';
import 'package:planning_and_skills_app_client/services/task_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreen extends StatefulWidget {
  static const routeName = '/calendarscreen';
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Task> tasksList = [];
  List<dynamic> remindersList = [];
  int? userID;
  DateTime _selectedDay = DateTime(
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

  Future<void> getUserReminders() async {
    print("getReminders called");
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
      remindersList = await ReminderService.getUserReminders(userId);
      setState(() {});
      print("remindersListAAA: $remindersList");
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

  @override
  void initState() {
    super.initState();
    requestNotificationPermissions();
    getUserReminders();
    getUserTasks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getUserTasks();
    getUserReminders();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<Task> tasksForSelectedDay = _groupedTasks[_selectedDay] ?? [];

    return Scaffold(
      backgroundColor: Color(0xfff1f2f6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GreetingsBar(),
                Calendar(
                  events: _groupedTasks,
                  onDaySelected: (selectedDay) {
                    setState(() {
                      _selectedDay = DateTime(
                          selectedDay.year, selectedDay.month, selectedDay.day);
                    });
                  },
                ),
                // SizedBox(
                //   height: screenHeight * 0.01,
                // ),
                CalendarTabs(
                  tasks: tasksForSelectedDay,
                  refreshTasks: getUserTasks,
                  reminders: remindersList,
                  refreshReminders: getUserReminders,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            builder: (BuildContext context) {
              return _buildBottomModalContent();
            },
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        backgroundColor: const Color(0xFFFF6F61),
        child: const Icon(
          Icons.add,
          color: Color(0xfff5f5f5),
        ),
      ),
    );
  }

  Widget _buildBottomModalContent() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.3, // Adjust as needed
      decoration: const BoxDecoration(
        color: Color(0xff2A3143),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const CreateTaskForm();
                      },
                    );
                  },
                  child: Container(
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.08,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6F61), // Orange color
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.note_add,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                const Text(
                  'New task',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(
              width: screenWidth * 0.2,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: AddReminderWidget(),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.08,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6F61),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.alarm,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                const Text(
                  'New reminder',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
