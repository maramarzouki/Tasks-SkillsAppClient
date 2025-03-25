import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planning_and_skills_app_client/config/extensions.dart';

class Task {
  String label, description;
  int startTime, endTime;
  int? taskId, interval, duration, durationUnit;
  Color taskColor;
  DateTime date;
  int complexity, priority, userId;
  bool isChecked;

  Task({
    required this.label,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.complexity,
    required this.priority,
    this.interval,
    this.duration,
    this.durationUnit,
    required this.isChecked,
    required this.userId,
    this.taskId,
    required this.taskColor,
  });

  String get formattedStartTime =>
      DateFormat('ha').format(DateTime.fromMillisecondsSinceEpoch(startTime));
  String get formattedEndTime =>
      DateFormat('ha').format(DateTime.fromMillisecondsSinceEpoch(endTime));

// Convert TaskModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (taskId != null) "taskId": taskId,
      'label': label,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'date': date.toLocal().toIso8601String(),
      'complexity': complexity,
      'priority': priority,
      'interval': interval,
      'duration': duration,
      'durationUnit': durationUnit,
      'userId': userId,
      'isChecked': isChecked,
      'taskColor': taskColor.toHex(),
    };
  }

  // Create a TaskModel from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      label: json['label'] ?? "",
      description: json['description'] ?? "",
      startTime: json['startTime'] ?? "",
      endTime: json['endTime'] ?? "",
      isChecked: json['IsChecked'] ?? false,
      taskId: json['id'] as int?,
      taskColor: HexColor.fromHex(json['taskColor']),
      date: DateTime.parse(json['date'] as String),
      complexity: json['complexity'] ?? "",
      priority: json['priority'] ?? "",
      userId: json['userId'] ?? "",
      interval: json['interval'] as int?,
      duration: json['duration'] as int?,
      durationUnit: json['durationUnit'] as int?,
    );
  }

  Task copyWith({
    String? label,
    description,
    int? startTime,
    endTime,
    int? taskId,
    interval,
    duration,
    durationUnit,
    Color? taskColor,
    DateTime? date,
    int? complexity,
    priority,
    userId,
    bool? isChecked,
  }) {
    return Task(
      description: description ?? this.description,
      endTime: endTime ?? this.endTime,
      durationUnit: durationUnit ?? this.durationUnit,
      taskColor: taskColor ?? this.taskColor,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      isChecked: isChecked ?? this.isChecked,
      label: label ?? this.label,
      startTime: startTime ?? this.startTime,
      complexity: complexity ?? this.complexity,
      priority: priority ?? this.priority,
      interval: interval ?? this.interval,
      duration: duration ?? this.duration,
      taskId: taskId ?? this.taskId,
    );
  }

  @override
  String toString() {
    return 'Task(label: $label, description: $description, startTime: $startTime, endTime: $endTime, isChecked: $isChecked, date: $date, complexity: $complexity, priority: $priority, userId: $userId, taskId: $taskId)';
  }
}
