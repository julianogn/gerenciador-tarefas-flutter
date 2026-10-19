import 'entities/task.dart';
import 'value_objects/task_status.dart';

/// Strategy pattern: each filter decides which tasks are visible.
enum TaskFilter {
  all('Todas'),
  pending('Pendentes'),
  done('Concluídas'),
  overdue('Atrasadas');

  const TaskFilter(this.label);

  final String label;

  bool matches(Task task, DateTime today) => switch (this) {
    TaskFilter.all => true,
    TaskFilter.pending => task.status != TaskStatus.done,
    TaskFilter.done => task.status == TaskStatus.done,
    TaskFilter.overdue => task.isOverdue(today),
  };
}

/// Strategy pattern: interchangeable orderings.
enum TaskSort {
  creation('Criação'),
  priority('Prioridade'),
  dueDate('Prazo');

  const TaskSort(this.label);

  final String label;

  int compare(Task a, Task b) => switch (this) {
    TaskSort.creation => a.createdAt.compareTo(b.createdAt),
    TaskSort.priority => b.priority.weight.compareTo(a.priority.weight),
    TaskSort.dueDate => (a.dueDate ?? DateTime(9999)).compareTo(b.dueDate ?? DateTime(9999)),
  };
}
