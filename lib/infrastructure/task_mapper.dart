import '../domain/entities/task.dart';
import '../domain/value_objects/priority.dart';
import '../domain/value_objects/task_status.dart';
import '../domain/value_objects/task_title.dart';

/// Data Mapper: converts between the domain model and its JSON form.
abstract final class TaskMapper {
  static Map<String, Object?> toJson(Task task) => {
    'id': task.id,
    'title': task.title.value,
    'description': task.description,
    'priority': task.priority.name,
    'status': task.status.name,
    'dueDate': task.dueDate?.toIso8601String(),
    'createdAt': task.createdAt.toIso8601String(),
  };

  static Task fromJson(Map<String, Object?> json) => Task(
    id: json['id']! as String,
    title: TaskTitle(json['title']! as String),
    description: json['description'] as String? ?? '',
    priority: Priority.values.byName(json['priority']! as String),
    status: TaskStatus.values.byName(json['status']! as String),
    dueDate: switch (json['dueDate']) {
      final String value => DateTime.parse(value),
      _ => null,
    },
    createdAt: DateTime.parse(json['createdAt']! as String),
  );
}
