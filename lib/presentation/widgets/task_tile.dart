import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';
import '../../domain/value_objects/priority.dart';
import '../../domain/value_objects/task_status.dart';
import 'date_format.dart';

enum TaskAction { start, complete, reopen, edit, delete }

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.today, required this.onAction});

  final Task task;
  final DateTime today;
  final ValueChanged<TaskAction> onAction;

  @override
  Widget build(BuildContext context) {
    final done = task.status == TaskStatus.done;
    final overdue = task.isOverdue(today);

    return Card(
      child: ListTile(
        leading: Checkbox(value: done, onChanged: (_) => onAction(done ? TaskAction.reopen : TaskAction.complete)),
        title: Text(task.title.value, style: done ? const TextStyle(decoration: TextDecoration.lineThrough) : null),
        subtitle: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _Badge(label: task.status.label),
            _Badge(label: 'Prioridade ${task.priority.label}', color: _priorityColor(task.priority)),
            if (task.dueDate != null) _Badge(label: 'Prazo ${formatDate(task.dueDate!)}'),
            if (overdue) const _Badge(label: 'Atrasada', color: Colors.orange),
          ],
        ),
        trailing: PopupMenuButton<TaskAction>(
          tooltip: 'Ações',
          onSelected: onAction,
          itemBuilder: (_) => [
            for (final action in _availableActions(task.status))
              PopupMenuItem(value: action, child: Text(_actionLabels[action]!)),
          ],
        ),
      ),
    );
  }

  static List<TaskAction> _availableActions(TaskStatus status) => [
    if (status.canMoveTo(TaskStatus.inProgress)) TaskAction.start,
    if (status.canMoveTo(TaskStatus.done)) TaskAction.complete,
    if (status.canMoveTo(TaskStatus.todo)) TaskAction.reopen,
    TaskAction.edit,
    TaskAction.delete,
  ];

  static const _actionLabels = {
    TaskAction.start: 'Iniciar',
    TaskAction.complete: 'Concluir',
    TaskAction.reopen: 'Reabrir',
    TaskAction.edit: 'Editar',
    TaskAction.delete: 'Excluir',
  };

  static Color? _priorityColor(Priority priority) => switch (priority) {
    Priority.high => Colors.red,
    Priority.medium => null,
    Priority.low => Colors.grey,
  };
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effective = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: effective),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: effective)),
    );
  }
}
