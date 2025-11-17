import 'package:mykrono/models/Task.dart';

class Space {
  final int? id; // Sembast int key
  final String name;
  final List<Task> tasks;

  Space({this.id, required this.name, this.tasks = const []});

  Space copyWith({int? id, String? name, List<Task>? tasks}) {
    return Space(
      id: id ?? this.id,
      name: name ?? this.name,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tasks': tasks.map((t) => t.toMap()).toList(),
    };
  }

  static Space fromRecord(int key, Map<String, dynamic> map) {
    final tList = (map['tasks'] as List<dynamic>?)
            ?.map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    return Space(
      id: key,
      name: map['name'] as String? ?? '',
      tasks: tList,
    );
  }
}