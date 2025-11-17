// ignore_for_file: file_names

import 'package:mykrono/core/screens/space_screen.dart';

class Task {
  final int id;
  final String text;
  final bool completed;
  final String dateTime; // stored as String (ISO8601)
  final Priority priority;

  Task({
    required this.dateTime,
    required this.priority,
    required this.id,
    required this.text,
    this.completed = false,
  });

  Task copyWith({
    int? id,
    String? text,
    bool? completed,
    String? dateTime,
    Priority? priority,
  }) {
    return Task(
      id: id ?? this.id,
      text: text ?? this.text,
      completed: completed ?? this.completed,
      dateTime: dateTime ?? this.dateTime,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'completed': completed,
      'dateTime': dateTime,
      'priority': priority.name, 
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      text: map['text'] as String,
      completed: map['completed'] as bool? ?? false,
      dateTime: map['dateTime'] as String,
      priority: Priority.values.firstWhere(
        (e) => e.name == map['priority'], 
      ),
    );
  }
}
