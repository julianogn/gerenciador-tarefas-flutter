import '../failures.dart';

/// Value object: a title is always trimmed and never blank.
final class TaskTitle {
  factory TaskTitle(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      throw const InvalidTitleFailure('O título não pode ser vazio.');
    }
    if (value.length > maxLength) {
      throw const InvalidTitleFailure('O título deve ter no máximo $maxLength caracteres.');
    }
    return TaskTitle._(value);
  }

  const TaskTitle._(this.value);

  static const maxLength = 120;

  final String value;

  @override
  bool operator ==(Object other) => other is TaskTitle && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
