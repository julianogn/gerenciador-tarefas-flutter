import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';
import '../../domain/task_filter.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_form_sheet.dart';
import '../widgets/task_tile.dart';

/// View (MVC): rebuilds whenever the controller notifies a change.
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key, required this.controller});

  final TaskController controller;

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TaskController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_showError);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_showError);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
        actions: [
          PopupMenuButton<TaskSort>(
            tooltip: 'Ordenar',
            icon: const Icon(Icons.sort),
            onSelected: _controller.changeSort,
            itemBuilder: (_) => [
              for (final sort in TaskSort.values)
                CheckedPopupMenuItem(value: sort, checked: sort == _controller.sort, child: Text(sort.label)),
            ],
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => Column(
          children: [
            _FilterBar(selected: _controller.filter, onSelected: _controller.changeFilter),
            Expanded(child: _buildList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    );
  }

  Widget _buildList() {
    if (_controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.tasks.isEmpty) {
      return const Center(child: Text('Nenhuma tarefa encontrada.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 88),
      itemCount: _controller.tasks.length,
      itemBuilder: (context, index) {
        final task = _controller.tasks[index];
        return TaskTile(
          key: ValueKey(task.id),
          task: task,
          today: _controller.today,
          onAction: (action) => _handle(action, task),
        );
      },
    );
  }

  Future<void> _add() async {
    final data = await TaskFormSheet.show(context);
    if (data == null) return;
    await _controller.add(
      title: data.title,
      description: data.description,
      priority: data.priority,
      dueDate: data.dueDate,
    );
  }

  Future<void> _handle(TaskAction action, Task task) async {
    switch (action) {
      case TaskAction.start:
        await _controller.start(task.id);
      case TaskAction.complete:
        await _controller.complete(task.id);
      case TaskAction.reopen:
        await _controller.reopen(task.id);
      case TaskAction.delete:
        await _controller.delete(task.id);
      case TaskAction.edit:
        final data = await TaskFormSheet.show(context, initial: task);
        if (data == null) return;
        await _controller.edit(
          task.id,
          title: data.title,
          description: data.description,
          priority: data.priority,
          dueDate: data.dueDate,
        );
    }
  }

  void _showError() {
    final error = _controller.error;
    if (error == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    _controller.clearError();
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final TaskFilter selected;
  final ValueChanged<TaskFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          for (final filter in TaskFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter.label),
                selected: filter == selected,
                onSelected: (_) => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }
}
