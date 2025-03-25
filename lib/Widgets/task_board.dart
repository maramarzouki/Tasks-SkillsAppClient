import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planning_and_skills_app_client/models/task.dart';
import 'package:planning_and_skills_app_client/services/task_service.dart';
import 'package:planning_and_skills_app_client/widgets/core/custom_list.dart';
import 'package:planning_and_skills_app_client/widgets/task_widget.dart';

class TasksBoard extends StatefulWidget {
  final List<Task> tasks;
  final Function() refreshTasks;

  const TasksBoard(
      {super.key, required this.tasks, required this.refreshTasks});

  @override
  _TasksBoardState createState() => _TasksBoardState();
}

class _TasksBoardState extends State<TasksBoard> {
  late List<Task> pendingTasks, doneTasks;

  @override
  void initState() {
    super.initState();
    _splitTasks();
  }

  @override
  void didUpdateWidget(covariant TasksBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _splitTasks();
  }

  void _splitTasks() {
    pendingTasks = widget.tasks.where((task) => !task.isChecked).toList();
    doneTasks = widget.tasks.where((task) => task.isChecked).toList();
  }

  Future<void> _updateTaskStatus(Task task, bool isChecked) async {
    debugPrint("_updateTaskStatus isChecked: $isChecked");
    try {
      await TaskService.checkTask(task.taskId, isChecked);
      setState(() {
        task.isChecked = isChecked;
        _splitTasks();
      });
      widget.refreshTasks();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Helper to build a draggable Task widget
  Widget _buildDraggableTask(Task task) {
    // DateTime startTime = DateTime.fromMillisecondsSinceEpoch(task.startTime);
    // DateTime endTime = DateTime.fromMillisecondsSinceEpoch(task.endTime);
    // String formattedStartTime = DateFormat('ha').format(startTime);
    // String formattedEndTime = DateFormat('ha').format(endTime);

    Widget taskContent = TaskWidget(
      task: task,
      onTaskDeleted: widget.refreshTasks,
    );
    debugPrint("buildDraggableTask $task $taskContent");

    return Draggable<Task>(
      data: task,
      feedback: SizedBox(
        width: 330, //match TaskWidget width
        height: 65, //match TaskWidget height
        child: Material(
          color: Colors.transparent,
          child: taskContent,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: taskContent,
      ),
      child: taskContent,
    );
  }

  Widget _buildSection(String title, List<Task> tasks, bool markDone) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 1,
        children: [
          SizedBox(
            height: 5,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          DragTarget<Task>(
            onAcceptWithDetails: (details) async {
              debugPrint("onAcceptWithDetails ${details.data}");
              await _updateTaskStatus(details.data, markDone);
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xfff1f2f6),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ListView(
                    children: [
                      // Build each task widget with some spacing
                      ...tasks.map((task) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: _buildDraggableTask(task),
                          )),
                    ],
                  ));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSection("Pending ⏳", pendingTasks, false),
        _buildSection("Done ✅", doneTasks, true),
      ],
    );
  }
}
