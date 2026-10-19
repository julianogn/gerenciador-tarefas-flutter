/// Base class for business rule violations.
sealed class DomainFailure implements Exception {
  const DomainFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class InvalidTitleFailure extends DomainFailure {
  const InvalidTitleFailure(super.message);
}

class InvalidTransitionFailure extends DomainFailure {
  const InvalidTransitionFailure(super.message);
}

class TaskNotFoundFailure extends DomainFailure {
  TaskNotFoundFailure(String id) : super("Tarefa '$id' não encontrada.");
}
