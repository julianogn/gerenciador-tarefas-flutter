enum TaskStatus {
  todo('A fazer'),
  inProgress('Em andamento'),
  done('Concluída');

  const TaskStatus(this.label);

  final String label;

  bool canMoveTo(TaskStatus target) => switch (this) {
    TaskStatus.todo => target == TaskStatus.inProgress || target == TaskStatus.done,
    TaskStatus.inProgress => target == TaskStatus.todo || target == TaskStatus.done,
    TaskStatus.done => target == TaskStatus.todo,
  };
}
