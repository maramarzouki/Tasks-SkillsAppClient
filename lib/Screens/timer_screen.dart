import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planning_and_skills_app_client/providers/time_provider.dart';
import 'package:provider/provider.dart';

class TimerScreen extends StatefulWidget {
  static const routeName = '/notificationsscreen';
  final int initialDuration;
  const TimerScreen({super.key, required this.initialDuration});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  void initState() {
    super.initState();
    // Update the provider with the initial duration after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timeProvider = Provider.of<TimeProvider>(context, listen: false);
      timeProvider.setTime(widget.initialDuration);
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeProvier = Provider.of<TimeProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xfff1f2f6),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(alignment: Alignment.center, children: [
            SizedBox(
              height: screenHeight * 0.4,
              width: screenWidth * 0.85,
              child: CircularProgressIndicator(
                backgroundColor: Colors.black12,
                value: timeProvier.initialTime > 0
                    ? timeProvier.remainingTime / timeProvier.initialTime
                    : 0,
                strokeWidth: 8,
                color: Color(0xff2A3143),
              ),
            ),
            GestureDetector(
              onTap: () => _showTimePicker(context, timeProvier),
              child: Text(
                _formatTime(timeProvier.remainingTime),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.125,
                    color: Color(0xff2A3143)),
              ),
            ),
          ]),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: timeProvier.isRunning
                    ? timeProvier.pauseTimer
                    : timeProvier.startTimer,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFFFF6F61)),
                  child: Icon(
                    timeProvier.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: timeProvier.resetTimer,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFFFF6F61)),
                  child: Icon(
                    Icons.stop,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          )
        ],
      )),
    );
  }

  //format the remaining time int a readable string
  String _formatTime(int totalSecond) {
    int hours = totalSecond ~/ 3600;
    int minutes = (totalSecond % 3600) ~/ 60;
    int seconds = totalSecond % 60;
    return "${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }

  // displays the cupertinoTimePicker to select the timer duration
  void _showTimePicker(BuildContext context, TimeProvider timerProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          height: 300,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hms,
            initialTimerDuration:
                Duration(seconds: timerProvider.remainingTime),
            onTimerDurationChanged: (Duration newDuration) {
              if (newDuration.inSeconds > 0) {
                timerProvider.setTime(newDuration.inSeconds);
              }
            },
          ),
        );
      },
    );
  }
}
