import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciador_tarefas/domain/entities/task.dart';
import 'package:gerenciador_tarefas/domain/value_objects/priority.dart';
import 'package:gerenciador_tarefas/infrastructure/shared_preferences_task_repository.dart';
import 'package:gerenciador_tarefas/infrastructure/task_mapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  final task = Task.create(
    id: 'abc',
    title: 'Persistir',
    description: 'em JSON',
    priority: Priority.high,
    dueDate: DateTime(2025, 12, 31),
    now: DateTime(2025, 3, 10, 8, 30),
  ).start();

  test('mapper round trip keeps every field', () {
    final restored = TaskMapper.fromJson(TaskMapper.toJson(task));

    expect(restored.id, task.id);
    expect(restored.title, task.title);
    expect(restored.description, task.description);
    expect(restored.priority, task.priority);
    expect(restored.status, task.status);
    expect(restored.dueDate, task.dueDate);
    expect(restored.createdAt, task.createdAt);
  });

  test('shared preferences repository saves, reads and deletes', () async {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    final repository = SharedPreferencesTaskRepository(SharedPreferencesAsync());

    await repository.save(task);
    expect((await repository.findById('abc'))?.status, task.status);

    await repository.delete('abc');
    expect(await repository.findAll(), isEmpty);
  });
}
