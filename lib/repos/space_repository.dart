import 'package:mykrono/core/database.dart';
import 'package:mykrono/core/screens/space_screen.dart';
import 'package:mykrono/models/space.dart';
import 'package:mykrono/models/Task.dart';
import 'package:sembast/sembast.dart';

final _spaceStore = intMapStoreFactory.store('spaces');

class SpaceRepository {
  Future<Database> get _db async => await AppDatabase.instance.database;

  // Create a new space and return its id
  Future<int> createSpace(String name) async {
    final db = await _db;
    final spaceMap = Space(name: name).toMap();
    final key = await _spaceStore.add(db, spaceMap);
    return key;
  }

  // Get all spaces
  Future<List<Space>> getAllSpaces() async {
    final db = await _db;
    final records = await _spaceStore.find(db);
    return records
        .map(
          (rec) => Space.fromRecord(
            rec.key,
            Map<String, dynamic>.from(rec.value),
          ),
        )
        .toList();
  }

  // Get a single space by id
  Future<Space?> getSpace(int id) async {
    final db = await _db;
    final rec = await _spaceStore.record(id).get(db) as Map<String, dynamic>?;
    if (rec == null) return null;
    return Space.fromRecord(id, rec);
  }

  // Add a task to a space
  Future<void> addTask(
      int spaceId, String text, DateTime? dateTime, Priority priority) async {
    final db = await _db;

    await db.transaction((txn) async {
      final record = _spaceStore.record(spaceId);
      final map = await record.get(txn) as Map<String, dynamic>?;

      if (map == null) {
        throw Exception('Space not found');
      }

      final tasks = List<Map<String, dynamic>>.from(map['tasks'] ?? []);

      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch,
        text: text,
        completed: false,
        dateTime: (dateTime ?? DateTime.now()).toIso8601String(),
        priority: priority,
      );

      tasks.add(task.toMap());

      await record.put(txn, {...map, 'tasks': tasks});
    });
  }

  // Update task text
  Future<void> updateTaskText(int spaceId, int taskId, String newText) async {
    final db = await _db;

    await db.transaction((txn) async {
      final record = _spaceStore.record(spaceId);
      final map = await record.get(txn) as Map<String, dynamic>?;

      if (map == null) throw Exception('Space not found');

      final tasks = List<Map<String, dynamic>>.from(map['tasks'] ?? []);
      var changed = false;

      final updated = tasks.map((t) {
        final m = Map<String, dynamic>.from(t);
        if (m['id'] == taskId) {
          m['text'] = newText;
          changed = true;
        }
        return m;
      }).toList();

      if (!changed) throw Exception('Task not found');

      await record.put(txn, {...map, 'tasks': updated});
    });
  }

  // Remove a task
  Future<void> removeTask(int spaceId, int taskId) async {
    final db = await _db;

    await db.transaction((txn) async {
      final record = _spaceStore.record(spaceId);
      final map = await record.get(txn) as Map<String, dynamic>?;

      if (map == null) throw Exception('Space not found');

      final tasks = List<Map<String, dynamic>>.from(map['tasks'] ?? []);
      final updated = tasks.where((t) => t['id'] != taskId).toList();

      if (updated.length == tasks.length) {
        throw Exception('Task not found');
      }

      await record.put(txn, {...map, 'tasks': updated});
    });
  }

  // Delete a space
  Future<void> deleteSpace(int spaceId) async {
    final db = await _db;
    await _spaceStore.record(spaceId).delete(db);
  }

  // Get recent tasks from all spaces (based on task.id timestamp)
  Future<List<Task>> getRecentTasksFromAllSpaces({int hours = 8}) async {
    final db = await _db;
    final records = await _spaceStore.find(db);

    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - Duration(hours: hours).inMilliseconds;

    final List<Task> recentTasks = [];

    for (final rec in records) {
      final map = Map<String, dynamic>.from(rec.value);
      final tasks = List<Map<String, dynamic>>.from(map['tasks'] ?? []);

      for (final t in tasks) {
        final timestamp = t['id'] as int;
        if (timestamp > cutoff) {
          recentTasks.add(Task.fromMap(t));
        }
      }
    }

    return recentTasks;
  }
}
