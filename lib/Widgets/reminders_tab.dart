import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planning_and_skills_app_client/Widgets/reminder_widget.dart';

class RemindersTab extends StatelessWidget {
  final List<dynamic> reminders;
  final VoidCallback refreshReminders;

  const RemindersTab({
    super.key,
    required this.reminders,
    required this.refreshReminders,
  });

  @override
  Widget build(BuildContext context) {
    return reminders.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              DateTime dateTime =
                  DateTime.parse(reminders[index]['reminderTime']);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ReminderWidget(
                  title: reminders[index]['title'],
                  reminderDate:
                      DateFormat('dd MMM yyyy, hh:mm a').format(dateTime),
                  isActive: reminders[index]['isActive'],
                  reminderId: reminders[index]['id'],
                  onReminderDeleted: refreshReminders,
                ),
              );
            },
          )
        : Center(
            child: Text(
              "No reminders at the moment!",
              style: TextStyle(color: Colors.grey),
            ),
          );
  }
}
