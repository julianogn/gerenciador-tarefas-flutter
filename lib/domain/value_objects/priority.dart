enum Priority {
  low('Baixa', 1),
  medium('Média', 2),
  high('Alta', 3);

  const Priority(this.label, this.weight);

  final String label;
  final int weight;
}
