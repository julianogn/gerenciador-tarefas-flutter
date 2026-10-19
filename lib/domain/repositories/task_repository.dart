import '../entities/task.dart';

/// Port defined by the domain; infrastructure supplies the implementation.
abstract interface class TaskRepository {
  Future<List<Task>> findAll();

  Future<Task?> findById(String id);

  Future<void> save(Task task);

  Future<void> delete(String id);
}
