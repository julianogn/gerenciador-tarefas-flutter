import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/task.dart';
import '../domain/repositories/task_repository.dart';
import 'task_mapper.dart';

/// Adapter: stores tasks on the device using shared_preferences.
class SharedPreferencesTaskRepository implements TaskRepository {
  SharedPreferencesTaskRepository(this._preferences);

  static const _storageKey = 'tasks';

  final SharedPreferencesAsync _preferences;

  @override
  Future<List<Task>> findAll() async => (await _load()).values.toList();

  @override
  Future<Task?> findById(String id) async => (await _load())[id];

  @override
  Future<void> save(Task task) async {
    final tasks = await _load();
    tasks[task.id] = task;
    await _write(tasks);
  }

  @override
  Future<void> delete(String id) async {
    final tasks = await _load();
    if (tasks.remove(id) != null) await _write(tasks);
  }

  Future<Map<String, Task>> _load() async {
    final raw = await _preferences.getString(_storageKey);
    if (raw == null) return {};
    final records = (jsonDecode(raw) as List).cast<Map<String, Object?>>();
    return {for (final record in records) record['id']! as String: TaskMapper.fromJson(record)};
  }

  Future<void> _write(Map<String, Task> tasks) {
    final records = tasks.values.map(TaskMapper.toJson).toList();
    return _preferences.setString(_storageKey, jsonEncode(records));
  }
}
