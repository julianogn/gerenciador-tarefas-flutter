import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';
import '../../domain/value_objects/priority.dart';
import '../../domain/value_objects/task_title.dart';
import 'date_format.dart';

class TaskFormData {
  const TaskFormData({required this.title, required this.description, required this.priority, this.dueDate});

  final String title;
  final String description;
  final Priority priority;
  final DateTime? dueDate;
}

/// Bottom sheet used both to create and to edit a task.
class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({super.key, this.initial});

  final Task? initial;

  static Future<TaskFormData?> show(BuildContext context, {Task? initial}) {
    return showModalBottomSheet<TaskFormData>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskFormSheet(initial: initial),
    );
  }

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(text: widget.initial?.title.value);
  late final _descriptionController = TextEditingController(text: widget.initial?.description);
  late Priority _priority = widget.initial?.priority ?? Priority.medium;
  late DateTime? _dueDate = widget.initial?.dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.viewInsetsOf(context).bottom + 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.initial == null ? 'Nova tarefa' : 'Editar tarefa',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('title-field'),
              controller: _titleController,
              autofocus: true,
              maxLength: TaskTitle.maxLength,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (value) => (value ?? '').trim().isEmpty ? 'O título é obrigatório.' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 12),
            SegmentedButton<Priority>(
              segments: [
                for (final priority in Priority.values) ButtonSegment(value: priority, label: Text(priority.label)),
              ],
              selected: {_priority},
              onSelectionChanged: (selection) => setState(() => _priority = selection.first),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(_dueDate == null ? 'Sem prazo' : 'Prazo: ${formatDate(_dueDate!)}')),
                if (_dueDate != null)
                  IconButton(
                    tooltip: 'Remover prazo',
                    onPressed: () => setState(() => _dueDate = null),
                    icon: const Icon(Icons.clear),
                  ),
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.event),
                  label: const Text('Escolher prazo'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _submit, child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      TaskFormData(
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _priority,
        dueDate: _dueDate,
      ),
    );
  }
}
