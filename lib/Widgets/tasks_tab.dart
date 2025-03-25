import 'package:flutter/material.dart';
import 'package:planning_and_skills_app_client/Widgets/task_board.dart';
import 'package:planning_and_skills_app_client/models/task.dart';

class TasksTab extends StatelessWidget {
  final List<Task> tasks;
  final VoidCallback refreshTasks;

  const TasksTab({
    super.key,
    required this.tasks,
    required this.refreshTasks,
  });

  @override
  Widget build(BuildContext context) {
    return tasks.isNotEmpty
        ? Column(
            children: [
              TasksBoard(
                tasks: tasks,
                refreshTasks: refreshTasks,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Long press on a task to delete it.",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        : Center(
            child: Text(
              "No tasks!",
              style: TextStyle(color: Colors.grey),
            ),
          );
  }
}
