import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciador_tarefas/domain/entities/task.dart';
import 'package:gerenciador_tarefas/domain/failures.dart';
import 'package:gerenciador_tarefas/domain/value_objects/task_status.dart';
import 'package:gerenciador_tarefas/domain/value_objects/task_title.dart';

void main() {
  final now = DateTime(2025, 3, 10);

  Task newTask({DateTime? dueDate}) => Task.create(id: '1', title: 'Revisar PR', now: now, dueDate: dueDate);

  group('TaskTitle', () {
    test('trims whitespace', () => expect(TaskTitle('  Estudar  ').value, 'Estudar'));

    test('rejects blank title', () => expect(() => TaskTitle('   '), throwsA(isA<InvalidTitleFailure>())));

    test('rejects long title', () {
      expect(() => TaskTitle('x' * (TaskTitle.maxLength + 1)), throwsA(isA<InvalidTitleFailure>()));
    });
  });

  group('Task', () {
    test('starts as todo', () => expect(newTask().status, TaskStatus.todo));

    test('moves through the workflow and returns new instances', () {
      final task = newTask();
      final started = task.start();
      final done = started.complete();

      expect(task.status, TaskStatus.todo);
      expect(started.status, TaskStatus.inProgress);
      expect(done.status, TaskStatus.done);
    });

    test('done task cannot be started', () {
      expect(() => newTask().complete().start(), throwsA(isA<InvalidTransitionFailure>()));
    });

    test('is overdue only when past due and not done', () {
      final task = newTask(dueDate: DateTime(2025, 3, 1));

      expect(task.isOverdue(now), isTrue);
      expect(task.complete().isOverdue(now), isFalse);
      expect(newTask(dueDate: now).isOverdue(now), isFalse);
    });

    test('edit can clear the due date', () {
      final edited = newTask(dueDate: now).edit(title: 'Novo', description: '', priority: newTask().priority);

      expect(edited.dueDate, isNull);
      expect(edited.title.value, 'Novo');
    });
  });
}
