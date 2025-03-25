import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:planning_and_skills_app_client/services/notifications_helper.dart';
import 'package:planning_and_skills_app_client/services/reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddReminderWidget extends StatefulWidget {
  const AddReminderWidget({super.key});

  @override
  State<AddReminderWidget> createState() => _AddReminderWidgetState();
}

class _AddReminderWidgetState extends State<AddReminderWidget> {
  final _reminderFormKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;

  bool _dateError = false;
  bool _startTimeError = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
        _dateError = false; // clear error when date is picked
      });
    }
  }

  Future<void> _pickStartTime() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (newTime != null) {
      setState(() {
        _startTime = newTime;
        _startTimeError = false;
      });
    }
  }

  String get _formattedDate {
    if (_selectedDate == null) return 'Select date';
    return DateFormat.yMMMd().format(_selectedDate!);
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  Future<void> createReminder() async {
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

    // Validate the form fields
    if (!_reminderFormKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      setState(() {
        _dateError = true;
      });
      return;
    }
    if (_startTime == null) {
      setState(() {
        _startTimeError = true;
      });
      return;
    }

    // Convert the selected time to an integer (e.g., total minutes since midnight)
    // int reminderTime = _startTime!.hour * 60 + _startTime!.minute;

    DateTime reminderTime = DateTime(_selectedDate!.year, _selectedDate!.month,
        _selectedDate!.day, _startTime!.hour, _startTime!.minute);

    print(
        "title: ${_titleController.text}, isActive: true, reminderTime: $reminderTime, userId: $userId,");

    try {
      String title = _titleController.text;
      final message = await ReminderService.createReminder(
        title: title,
        isActive: true,
        reminderTime: reminderTime,
        userId: userId,
      );
      print("reminderNotificationTime ${reminderTime}");
      NotificationHelper.scheduleNotification(
          message['id'], title, reminderTime);
      Fluttertoast.showToast(
          msg: "Reminder created successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: MediaQuery.of(context).size.width * 0.04);
      Navigator.of(context).pushNamed('/navbar');
    } catch (error) {
      print("PROBLEM ${error.toString()}");
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Form(
            key: _reminderFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Reminder',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2A3143),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      iconSize: screenWidth * 0.05,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.001),
                _buildRequiredTextField(
                  label: 'Title',
                  controller: _titleController,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Enter a title' : null,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildDatePickerField(
                  label: 'Date',
                  value: _formattedDate,
                  onTap: _pickDate,
                ),
                if (_dateError)
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.01),
                    child: Text(
                      'Select a date',
                      style: TextStyle(
                          color: Colors.red, fontSize: screenWidth * 0.035),
                    ),
                  ),
                SizedBox(height: screenHeight * 0.02),
                _buildTimePickerField(
                  label: 'Start time',
                  value: _formatTime(_startTime),
                  onTap: _pickStartTime,
                ),
                if (_startTimeError)
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.01),
                    child: Text(
                      'Select a start time',
                      style: TextStyle(
                          color: Colors.red, fontSize: screenWidth * 0.035),
                    ),
                  ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.05,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F61),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      createReminder();
                    },
                    child: const Text(
                      'Create',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildRequiredTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int minLines = 1,
    int maxLines = 1,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: screenHeight * 0.06,
              decoration: _fieldDecoration(),
              child: TextField(
                controller: controller,
                minLines: minLines,
                maxLines: maxLines,
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03,
                    vertical: MediaQuery.of(context).size.height * 0.01,
                  ),
                ),
                onChanged: (value) {
                  state.didChange(value);
                },
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.09,
      decoration: _fieldDecoration(),
      child: ListTile(
        onTap: onTap,
        title: Text(label, style: const TextStyle(color: Colors.grey)),
        subtitle: Text(value,
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045)),
        trailing: const Icon(
          Icons.calendar_today,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTimePickerField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: _fieldDecoration(),
      child: ListTile(
        onTap: onTap,
        title: Text(label, style: const TextStyle(color: Colors.grey)),
        subtitle: Text(value,
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
        trailing: const Icon(Icons.access_time),
      ),
    );
  }
}
