import 'package:flutter/material.dart';
import 'package:planning_and_skills_app_client/Widgets/reminders_tab.dart';
import 'package:planning_and_skills_app_client/Widgets/tasks_tab.dart';
import 'package:planning_and_skills_app_client/models/task.dart';

class CalendarTabs extends StatelessWidget {
  final List<Task> tasks;
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
    print("TASKS $tasks");
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
          Builder(builder: (context) {
            final controller = DefaultTabController.of(context);
            return ListenableBuilder(
                listenable: controller,
                builder: (context, child) {
                  return IndexedStack(
                    index: controller.index,
                    children: [
                      TasksTab(tasks: tasks, refreshTasks: refreshTasks),
                      RemindersTab(
                          reminders: reminders,
                          refreshReminders: refreshReminders),
                    ],
                  );
                });
          })
        ],
      ),
    );
  }
}
