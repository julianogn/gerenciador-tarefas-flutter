import '../failures.dart';
import '../value_objects/priority.dart';
import '../value_objects/task_status.dart';
import '../value_objects/task_title.dart';

/// Aggregate root. Immutable: every change returns a new instance,
/// which keeps state predictable for the UI.
final class Task {
  const Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description = '',
    this.priority = Priority.medium,
    this.status = TaskStatus.todo,
    this.dueDate,
  });

  factory Task.create({
    required String id,
    required String title,
    required DateTime now,
    String description = '',
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) {
    return Task(
      id: id,
      title: TaskTitle(title),
      description: description.trim(),
      priority: priority,
      dueDate: dueDate,
      createdAt: now,
    );
  }

  final String id;
  final TaskTitle title;
  final String description;
  final Priority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime createdAt;

  Task start() => _moveTo(TaskStatus.inProgress);

  Task complete() => _moveTo(TaskStatus.done);

  Task reopen() => _moveTo(TaskStatus.todo);

  Task edit({required String title, required String description, required Priority priority, DateTime? dueDate}) {
    return Task(
      id: id,
      title: TaskTitle(title),
      description: description.trim(),
      priority: priority,
      status: status,
      dueDate: dueDate,
      createdAt: createdAt,
    );
  }

  bool isOverdue(DateTime today) {
    final due = dueDate;
    if (due == null || status == TaskStatus.done) return false;
    return DateTime(due.year, due.month, due.day).isBefore(DateTime(today.year, today.month, today.day));
  }

  Task _moveTo(TaskStatus target) {
    if (!status.canMoveTo(target)) {
      throw InvalidTransitionFailure('Não é possível mudar de "${status.label}" para "${target.label}".');
    }
    return Task(
      id: id,
      title: title,
      description: description,
      priority: priority,
      status: target,
      dueDate: dueDate,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Task && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
