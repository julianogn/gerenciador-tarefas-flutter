import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciador_tarefas/application/task_service.dart';
import 'package:gerenciador_tarefas/domain/failures.dart';
import 'package:gerenciador_tarefas/domain/task_filter.dart';
import 'package:gerenciador_tarefas/domain/value_objects/priority.dart';
import 'package:gerenciador_tarefas/infrastructure/in_memory_task_repository.dart';

void main() {
  late TaskService service;
  var nextId = 0;
  var clock = DateTime(2025, 3, 10);

  setUp(() {
    nextId = 0;
    clock = DateTime(2025, 3, 10);
    service = TaskService(InMemoryTaskRepository(), clock: () => clock, idGenerator: () => '${++nextId}');
  });

  test('filters done tasks', () async {
    final first = await service.create(title: 'A');
    await service.create(title: 'B');
    await service.complete(first.id);

    final done = await service.list(filter: TaskFilter.done);

    expect(done.map((task) => task.title.value), ['A']);
  });

  test('sorts by priority', () async {
    await service.create(title: 'Baixa', priority: Priority.low);
    await service.create(title: 'Alta', priority: Priority.high);

    final tasks = await service.list(sort: TaskSort.priority);

    expect(tasks.map((task) => task.title.value), ['Alta', 'Baixa']);
  });

  test('lists only overdue tasks', () async {
    await service.create(title: 'Atrasada', dueDate: DateTime(2025, 3, 1));
    await service.create(title: 'No prazo', dueDate: DateTime(2025, 4, 1));

    final tasks = await service.list(filter: TaskFilter.overdue);

    expect(tasks.map((task) => task.title.value), ['Atrasada']);
  });

  test('unknown task fails', () {
    expect(service.complete('nao-existe'), throwsA(isA<TaskNotFoundFailure>()));
  });

  test('delete removes task', () async {
    final task = await service.create(title: 'Temporária');

    await service.delete(task.id);

    expect(await service.list(), isEmpty);
  });
}
