/// How often a recurring transaction repeats.
enum RecurrenceFrequency {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly'),
  yearly('Yearly');

  final String label;
  const RecurrenceFrequency(this.label);
}
