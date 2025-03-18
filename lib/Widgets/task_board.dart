import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planning_and_skills_app_client/services/task_service.dart';
import 'package:planning_and_skills_app_client/Widgets/task_widget.dart';

class TasksBoard extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  final Function() refreshTasks;

  const TasksBoard(
      {super.key, required this.tasks, required this.refreshTasks});

  @override
  _TasksBoardState createState() => _TasksBoardState();
}

class _TasksBoardState extends State<TasksBoard> {
  late List<Map<String, dynamic>> pendingTasks;
  late List<Map<String, dynamic>> doneTasks;

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
    pendingTasks =
        widget.tasks.where((task) => task['isChecked'] == false).toList();
    doneTasks =
        widget.tasks.where((task) => task['isChecked'] == true).toList();
  }

  Future<void> _updateTaskStatus(
      Map<String, dynamic> task, bool isChecked) async {
    try {
      await TaskService.checkTask(task['id'], isChecked);
      setState(() {
        task['isChecked'] = isChecked;
        _splitTasks();
      });
      widget.refreshTasks();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Helper to build a draggable Task widget
  Widget _buildDraggableTask(Map<String, dynamic> task) {
    Color taskColor = Color(
      int.parse(task['taskColor'].replaceFirst('#', '0xff')),
    );
    DateTime startTime = DateTime.fromMillisecondsSinceEpoch(task['startTime']);
    DateTime endTime = DateTime.fromMillisecondsSinceEpoch(task['endTime']);
    String formattedStartTime = DateFormat('ha').format(startTime);
    String formattedEndTime = DateFormat('ha').format(endTime);

    Widget taskContent = TaskWidget(
      taskId: task['id'],
      title: task['label'],
      isCheckedState: task['isChecked'],
      taskColorIndicator: taskColor,
      description: task['description'],
      startTime: formattedStartTime,
      endTime: formattedEndTime,
      onTaskDeleted: widget.refreshTasks,
    );

    return Draggable<Map<String, dynamic>>(
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

  Widget _buildSection(
      String title, List<Map<String, dynamic>> tasks, bool markDone) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 5,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: DragTarget<Map<String, dynamic>>(
                onAcceptWithDetails: (details) async {
                  await _updateTaskStatus(details.data, markDone);
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    height: 250.0, // Set your desired height here
                    padding: const EdgeInsets.only(left: 17, right: 17, top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                      // border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: ListView(
                      children: [
                        // Build each task widget with some spacing
                        ...tasks.map((task) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: _buildDraggableTask(task),
                            )),
                      ],
                    ),
                    // child: ListView.builder(
                    //   itemCount: tasks.length,
                    //   itemBuilder: (context, index) {
                    //     return Padding(
                    //       padding: const EdgeInsets.symmetric(vertical: 4.0),
                    //       child: _buildDraggableTask(tasks[index]),
                    //     );
                    //   },
                    // ),
                  );
                },
              ),
            ),
          ],
        ),
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
