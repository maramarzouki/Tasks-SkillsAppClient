import 'package:flutter/material.dart';
import 'package:planning_and_skills_app_client/Widgets/reminders_tab.dart';
import 'package:planning_and_skills_app_client/Widgets/tasks_tab.dart';

class CalendarTabs extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final VoidCallback refreshTasks;
  final List<dynamic> reminders;
  final VoidCallback refreshReminders;
  const CalendarTabs(
      {super.key,
      required this.tasks,
      required this.refreshTasks,
      required this.reminders,
      required this.refreshReminders});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(5),
            child: TabBar(
              indicatorColor: const Color(0xFFFF6F61),
              labelColor: const Color(0xFFFF6F61),
              tabs: [
                Tab(
                  // icon: Icon(Icons.format_list_bulleted_rounded),
                  text: "Tasks",
                ),
                Tab(
                  text: "Reminders",
                  // icon: Icon(Icons.notifications_on_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                TasksTab(tasks: tasks, refreshTasks: refreshTasks),
                RemindersTab(
                    reminders: reminders, refreshReminders: refreshReminders),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
