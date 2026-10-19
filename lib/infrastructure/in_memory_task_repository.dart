import '../domain/entities/task.dart';
import '../domain/repositories/task_repository.dart';

class InMemoryTaskRepository implements TaskRepository {
  final Map<String, Task> _tasks = {};

  @override
  Future<List<Task>> findAll() async => _tasks.values.toList();

  @override
  Future<Task?> findById(String id) async => _tasks[id];

  @override
  Future<void> save(Task task) async => _tasks[task.id] = task;

  @override
  Future<void> delete(String id) async => _tasks.remove(id);
}
