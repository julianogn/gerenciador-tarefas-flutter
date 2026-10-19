import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciador_tarefas/app.dart';
import 'package:gerenciador_tarefas/application/task_service.dart';
import 'package:gerenciador_tarefas/infrastructure/in_memory_task_repository.dart';
import 'package:gerenciador_tarefas/presentation/controllers/task_controller.dart';

void main() {
  testWidgets('adds a task and completes it', (tester) async {
    final controller = TaskController(TaskService(InMemoryTaskRepository()));
    await tester.pumpWidget(TaskApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma tarefa encontrada.'), findsOneWidget);

    await tester.tap(find.text('Nova tarefa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('title-field')), 'Estudar Flutter');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Estudar Flutter'), findsOneWidget);
    expect(find.text('A fazer'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(find.text('Concluída'), findsOneWidget);
  });

  testWidgets('blank title shows validation message', (tester) async {
    final controller = TaskController(TaskService(InMemoryTaskRepository()));
    await tester.pumpWidget(TaskApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nova tarefa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('O título é obrigatório.'), findsOneWidget);
  });
}
