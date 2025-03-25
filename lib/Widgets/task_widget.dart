import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:planning_and_skills_app_client/models/task.dart';
import 'package:planning_and_skills_app_client/services/task_service.dart';

class TaskWidget extends StatefulWidget {
  final Task task;
  final Function() onTaskDeleted;
  final Function()? startTaskTimer;
  const TaskWidget(
      {super.key,
      required this.onTaskDeleted,
      this.startTaskTimer,
      required this.task});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  late bool isChecked;
  bool _isHighlighted = false;

  // Future<void> checkTask() async {
  //   final previousState = isChecked;
  //   try {
  //     final taskID = widget.task.taskId;
  //     final response = await TaskService.checkTask(taskID, !isChecked);
  //     setState(() {
  //       isChecked = !isChecked;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isChecked = previousState;
  //     });
  //     debugPrint(e.toString());
  //   }
  // }

  Future<void> deleteTask() async {
    try {
      final taskID = widget.task.taskId;
      final response = await TaskService.deleteTask(taskID);
      Fluttertoast.showToast(
          msg: response,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: MediaQuery.of(context).size.width * 0.04);
      Navigator.of(context).pop();
      widget.onTaskDeleted();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    isChecked = widget.task.isChecked;
  }

  @override
  void didUpdateWidget(covariant TaskWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.isChecked != widget.task.isChecked) {
      setState(() {
        isChecked = widget.task.isChecked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: InkWell(
        onHighlightChanged: (isPressed) {
          setState(() {
            _isHighlighted = isPressed;
          });
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Delete task"),
              content: const Text("Are you sure you want to delete this task?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    deleteTask();
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
        onTap: () => {
          if (widget.startTaskTimer != null) {widget.startTaskTimer!()}
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.task.taskColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      widget.task.description,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    // Checkbox(
                    //     value: isChecked,
                    //     onChanged: (value) {
                    //       checkTask();
                    //     })
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${widget.task.formattedStartTime} - ${widget.task.formattedEndTime}",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        // child: Container(
        //   width: double.infinity,
        //   height: screenHeight * 0.07,
        //   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        //   decoration: BoxDecoration(
        //     border: Border.all(
        //       color: _isHighlighted ? Colors.red : widget.taskColorIndicator,
        //       width: 2.0,
        //     ),
        //     color: _isHighlighted ? Colors.red : const Color(0xffF9F9F9),
        //     borderRadius: BorderRadius.circular(12),
        //     boxShadow: const [
        //       BoxShadow(
        //         color: Colors.black12,
        //         blurRadius: 4,
        //         offset: Offset(0, 2),
        //       ),
        //     ],
        //   ),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: Text(
        //           widget.title ?? '',
        //           style: TextStyle(
        //             fontSize: screenWidth * 0.045,
        //             color:
        //                 _isHighlighted ? Colors.white : const Color(0xff2A3143),
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //       Checkbox(
        //         value: isChecked,
        //         onChanged: (bool? value) {
        //           checkTask();
        //         },
        //         activeColor: const Color(0xff2A3143),
        //         checkColor: Colors.white,
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
