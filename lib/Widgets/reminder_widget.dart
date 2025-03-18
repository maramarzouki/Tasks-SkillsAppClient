import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:planning_and_skills_app_client/services/notifications_helper.dart';
import 'package:planning_and_skills_app_client/services/reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderWidget extends StatefulWidget {
  final String title;
  final bool? isActive;
  final String reminderDate;
  final int reminderId;
  final Function() onReminderDeleted;
  const ReminderWidget(
      {super.key,
      required this.title,
      this.isActive,
      required this.reminderDate,
      required this.reminderId,
      required this.onReminderDeleted});

  @override
  State<ReminderWidget> createState() => _ReminderWidgetState();
}

class _ReminderWidgetState extends State<ReminderWidget> {
  late bool isSwitched;
  bool _isHighlighted = false;

  Future<void> toggleReminder() async {
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

    final previousState = isSwitched;
    try {
      print("mlowl $isSwitched");
      final reminderID = widget.reminderId;
      final reminderTime =
          DateFormat("dd MMM yyyy, hh:mm a").parse(widget.reminderDate);
      final response =
          await ReminderService.toggleReminder(userId, reminderID, !isSwitched);
      setState(() {
        isSwitched = !isSwitched;
      });
      if (isSwitched) {
        NotificationHelper.scheduleNotification(
            reminderID, widget.title, reminderTime);
      } else {
        NotificationHelper.cancelNotification(reminderID);
      }
    } catch (e) {
      print("mlekher $isSwitched ${e.toString()}");
      setState(() {
        isSwitched = previousState;
      });
      debugPrint("LENNA ${e.toString()}");
    }
  }

  Future<void> deleteReminder() async {
    try {
      final reminderID = widget.reminderId;
      final response = await ReminderService.deleteReminder(reminderID);
      Fluttertoast.showToast(
          msg: response,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: MediaQuery.of(context).size.width * 0.04);
      Navigator.of(context).pop();
      widget.onReminderDeleted();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    isSwitched = widget.isActive ?? false;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
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
            title: const Text("Delete reminder"),
            content:
                const Text("Are you sure you want to delete this reminder?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  deleteReminder();
                },
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: _isHighlighted ? Colors.red : const Color(0xffF9F9F9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title ?? 'Reminder',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: _isHighlighted
                          ? Colors.white
                          : const Color(0xff2A3143),
                    )),
                SizedBox(height: screenHeight * 0.006),
                Text(
                  '${widget.reminderDate}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: _isHighlighted ? Colors.white : Colors.grey[600],
                  ),
                ),
              ],
            ),
            Switch(
              value: isSwitched,
              onChanged: (bool value) {
                toggleReminder();
                // setState(() {
                //   isSwitched = value;
                // });
              },
              activeColor: Colors.white,
              // activeTrackColor: const Color(0xFFFF6F61),
              activeTrackColor: const Color(0xff2A3143),
            ),
          ],
        ),
      ),
    );
  }
}
