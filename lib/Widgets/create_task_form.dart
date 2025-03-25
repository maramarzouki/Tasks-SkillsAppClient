import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:planning_and_skills_app_client/config/extensions.dart';
import 'package:planning_and_skills_app_client/models/task.dart';
import 'package:planning_and_skills_app_client/screens/navbar.dart';
import 'package:planning_and_skills_app_client/services/task_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Make sure you have your baseUrl defined somewhere:
const String baseUrl = 'https://your-api-url.com';

class CreateTaskForm extends StatefulWidget {
  const CreateTaskForm({super.key});

  @override
  State<CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends State<CreateTaskForm> {
  // GlobalKey for Form validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Complexity options
  final List<String> _complexities = ['Low', 'Medium', 'High'];
  String _selectedComplexity = 'Low';

  // Date, Start Time, End Time
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Error flags for pickers
  bool _dateError = false;
  bool _startTimeError = false;
  bool _endTimeError = false;

  // Task indicator colors
  final List<Color> _indicatorColors = [
    Color(0xffABC4FF),
    Color(0xffC3AAEF),
    Color(0xffAEC6CF),
    Color(0xffE78284),
    Color(0xffFDE293),
    Color(0xffF6C571),
    Color(0xffF2CFD0),
    Color(0xff83B89B),
  ];
  int _selectedIndicatorIndex = 0;

  // Repeat values
  int _repeatDays = 2;
  int _repeatMonths = 1;

  // New repeat unit options (Month or Week)
  final List<String> _repeatUnits = ['Month(s)', 'Week(s)'];
  String _selectedRepeatUnit = 'Month(s)';

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
        _dateError = false; //clear error when date is picked
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

  Future<void> _pickEndTime() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (newTime != null) {
      setState(() {
        _endTime = newTime;
        _endTimeError = false;
      });
    }
  }

  // Format date and time for display
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

  // Validate & create task
  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _startTime == null || _endTime == null) {
      setState(() {
        _dateError = _selectedDate == null;
        _startTimeError = _startTime == null;
        _endTimeError = _endTime == null;
      });
      return;
    }

    final String label = _nameController.text.trim();
    final String description = _descriptionController.text.trim();

    final DateTime startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final DateTime endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final int startTimeEpoch = startDateTime.millisecondsSinceEpoch;
    final int endTimeEpoch = endDateTime.millisecondsSinceEpoch;

    // Map complexity from String to int.
    int complexityInt = _selectedComplexity == 'Low'
        ? 0
        : _selectedComplexity == 'Medium'
            ? 1
            : 2;
    int priorityInt = complexityInt;

    // Map repeat fields to interval/duration.
    int interval = _repeatDays;
    int intervalUnit = 0; // Assuming 0 represents day.
    int duration = _repeatMonths;
    int durationUnit =
        _selectedRepeatUnit == 'Month(s)' ? 2 : 1; // Month=2, Week=1.
    bool isChecked = false;

    // Convert selected color to a hex string (e.g. "#FF2196F3")
    final String taskColor =
        "#${_indicatorColors[_selectedIndicatorIndex].value.toRadixString(16).padLeft(8, '0')}";

    // Retrieve userId from token.
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

    try {
      final newTask = Task(
        label: label,
        description: description,
        startTime: startTimeEpoch,
        endTime: endTimeEpoch,
        date: _selectedDate!,
        complexity: complexityInt,
        priority: priorityInt,
        taskColor: _indicatorColors[_selectedIndicatorIndex],
        interval: interval,
        duration: duration,
        durationUnit: durationUnit,
        isChecked: isChecked,
        userId: userId,
      );
      final String message = await TaskService.createTask(newTask);
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: MediaQuery.of(context).size.width * 0.04);
      Navigator.of(context).pushNamed(Navbar.routeName);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'New task',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Name field - required
                _buildRequiredTextField(
                  label: 'Name',
                  controller: _nameController,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Enter a name' : null,
                ),
                SizedBox(height: screenHeight * 0.02),
                // Description field - required
                _buildRequiredTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Enter a description'
                      : null,
                ),
                SizedBox(height: screenHeight * 0.02),
                // Complexity dropdown
                _buildRequiredDropdownField(
                  label: 'Complexity',
                  value: _selectedComplexity,
                  items: _complexities,
                  onChanged: (val) {
                    setState(() {
                      _selectedComplexity = val!;
                    });
                  },
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Select a complexity'
                      : null,
                ),
                SizedBox(height: screenHeight * 0.02),
                // Date field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                // Start and End time fields
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                    color: Colors.red,
                                    fontSize: screenWidth * 0.035),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTimePickerField(
                            label: 'End time',
                            value: _formatTime(_endTime),
                            onTap: _pickEndTime,
                          ),
                          if (_endTimeError)
                            Padding(
                              padding: EdgeInsets.only(top: screenWidth * 0.01),
                              child: Text(
                                'Select an end time',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: screenWidth * 0.035),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                // Task indicator (colored dots)
                _buildTaskIndicatorRow(),
                SizedBox(height: screenHeight * 0.02),
                // Repeat row
                _buildRepeatRow(),
                SizedBox(height: screenHeight * 0.02),
                // Create button
                SizedBox(
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.06,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F61),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: _createTask,
                    child: const Text(
                      'Create',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom widget for required text fields
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
                padding: EdgeInsets.only(top: screenWidth * 0.01),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                      color: Colors.red, fontSize: screenWidth * 0.035),
                ),
              )
          ],
        );
      },
    );
  }

  // Custom widget for required dropdown fields
  Widget _buildRequiredDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: _fieldDecoration(),
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: DropdownButtonFormField<String>(
                value: value,
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                  errorStyle: const TextStyle(height: 0),
                ),
                items: items
                    .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (val) {
                  onChanged(val);
                  state.didChange(val);
                },
              ),
            ),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.01),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                      color: Colors.red, fontSize: screenWidth * 0.035),
                ),
              )
          ],
        );
      },
    );
  }

  // Date picker field widget
  Widget _buildDatePickerField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: _fieldDecoration(),
      child: ListTile(
        onTap: onTap,
        title: Text(label, style: const TextStyle(color: Colors.grey)),
        subtitle: Text(value, style: TextStyle(fontSize: screenWidth * 0.045)),
        trailing: const Icon(Icons.calendar_today),
      ),
    );
  }

  // Time picker field widget
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
                TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045)),
        trailing: const Icon(Icons.access_time),
      ),
    );
  }

  // Task indicator row widget
  Widget _buildTaskIndicatorRow() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: _fieldDecoration(),
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02, vertical: screenHeight * 0.01),
      child: Column(
        children: [
          const Text('Task indicator', style: TextStyle(color: Colors.grey)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < _indicatorColors.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndicatorIndex = i;
                    });
                  },
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                    width: screenWidth * 0.07,
                    height: screenHeight * 0.04,
                    decoration: BoxDecoration(
                      color: _indicatorColors[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (i == _selectedIndicatorIndex)
                            ? Colors.white
                            : Colors.transparent,
                        width: screenWidth * 0.005,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncrementDecrement({
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRoundButton(icon: Icons.remove, onPressed: onDecrement),
        SizedBox(width: screenWidth * 0.02),
        Text('$value'),
        SizedBox(width: screenWidth * 0.02),
        _buildRoundButton(icon: Icons.add, onPressed: onIncrement),
      ],
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: screenWidth * 0.04),
      ),
    );
  }

  Widget _buildRepeatRow() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: _fieldDecoration(),
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Repeat this task every'),
              SizedBox(width: screenWidth * 0.04),
              _buildIncrementDecrement(
                value: _repeatDays,
                onDecrement: () {
                  setState(() {
                    if (_repeatDays > 1) _repeatDays--;
                  });
                },
                onIncrement: () {
                  setState(() {
                    _repeatDays++;
                  });
                },
              ),
              SizedBox(width: screenWidth * 0.04),
              const Text('day(s)'),
            ],
          ),
          SizedBox(height: screenHeight * 0.001),
          Row(
            children: [
              const Text('For'),
              SizedBox(width: screenWidth * 0.04),
              _buildIncrementDecrement(
                value: _repeatMonths,
                onDecrement: () {
                  setState(() {
                    if (_repeatMonths > 1) _repeatMonths--;
                  });
                },
                onIncrement: () {
                  setState(() {
                    _repeatMonths++;
                  });
                },
              ),
              SizedBox(width: screenWidth * 0.04),
              DropdownButton<String>(
                value: _selectedRepeatUnit,
                items: _repeatUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedRepeatUnit = val!;
                  });
                },
                underline: Container(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}
