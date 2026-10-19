import 'dart:math';

import '../domain/entities/task.dart';
import '../domain/failures.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/task_filter.dart';
import '../domain/value_objects/priority.dart';

typedef Clock = DateTime Function();
typedef IdGenerator = String Function();

/// Application service: one method per use case. Rules stay in the domain.
class TaskService {
  TaskService(this._repository, {Clock? clock, IdGenerator? idGenerator})
    : _clock = clock ?? DateTime.now,
      _idGenerator = idGenerator ?? _randomId;

  final TaskRepository _repository;
  final Clock _clock;
  final IdGenerator _idGenerator;

  DateTime get today => _clock();

  Future<List<Task>> list({TaskFilter filter = TaskFilter.all, TaskSort sort = TaskSort.creation}) async {
    final now = _clock();
    final tasks = await _repository.findAll();
    return tasks.where((task) => filter.matches(task, now)).toList()..sort(sort.compare);
  }

  Future<Task> create({
    required String title,
    String description = '',
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) async {
    final task = Task.create(
      id: _idGenerator(),
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      now: _clock(),
    );
    await _repository.save(task);
    return task;
  }

  Future<Task> edit(
    String id, {
    required String title,
    required String description,
    required Priority priority,
    DateTime? dueDate,
  }) {
    return _update(
      id,
      (task) => task.edit(title: title, description: description, priority: priority, dueDate: dueDate),
    );
  }

  Future<Task> start(String id) => _update(id, (task) => task.start());

  Future<Task> complete(String id) => _update(id, (task) => task.complete());

  Future<Task> reopen(String id) => _update(id, (task) => task.reopen());

  Future<void> delete(String id) async {
    await _load(id);
    await _repository.delete(id);
  }

  Future<Task> _update(String id, Task Function(Task) change) async {
    final updated = change(await _load(id));
    await _repository.save(updated);
    return updated;
  }

  Future<Task> _load(String id) async {
    final task = await _repository.findById(id);
    if (task == null) throw TaskNotFoundFailure(id);
    return task;
  }

  static String _randomId() {
    final random = Random.secure();
    return List.generate(16, (_) => random.nextInt(16).toRadixString(16)).join();
  }
}
