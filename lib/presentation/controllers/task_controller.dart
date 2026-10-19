import 'package:flutter/foundation.dart';

import '../../application/task_service.dart';
import '../../domain/entities/task.dart';
import '../../domain/failures.dart';
import '../../domain/task_filter.dart';
import '../../domain/value_objects/priority.dart';

/// Controller (MVC): holds screen state and notifies views when it changes (Observer pattern).
class TaskController extends ChangeNotifier {
  TaskController(this._service);

  final TaskService _service;

  List<Task> _tasks = const [];
  TaskFilter _filter = TaskFilter.all;
  TaskSort _sort = TaskSort.creation;
  bool _loading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  TaskFilter get filter => _filter;
  TaskSort get sort => _sort;
  bool get loading => _loading;
  String? get error => _error;
  DateTime get today => _service.today;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    await _refresh();
    _loading = false;
    notifyListeners();
  }

  Future<void> changeFilter(TaskFilter filter) async {
    _filter = filter;
    await _run(() async {});
  }

  Future<void> changeSort(TaskSort sort) async {
    _sort = sort;
    await _run(() async {});
  }

  Future<void> add({
    required String title,
    required String description,
    required Priority priority,
    DateTime? dueDate,
  }) {
    return _run(() => _service.create(title: title, description: description, priority: priority, dueDate: dueDate));
  }

  Future<void> edit(
    String id, {
    required String title,
    required String description,
    required Priority priority,
    DateTime? dueDate,
  }) {
    return _run(() => _service.edit(id, title: title, description: description, priority: priority, dueDate: dueDate));
  }

  Future<void> start(String id) => _run(() => _service.start(id));

  Future<void> complete(String id) => _run(() => _service.complete(id));

  Future<void> reopen(String id) => _run(() => _service.reopen(id));

  Future<void> delete(String id) => _run(() => _service.delete(id));

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() operation) async {
    try {
      await operation();
      _error = null;
    } on DomainFailure catch (failure) {
      _error = failure.message;
    }
    await _refresh();
    notifyListeners();
  }

  Future<void> _refresh() async {
    _tasks = await _service.list(filter: _filter, sort: _sort);
  }
}
