/// Predefined spending/income categories.
///
/// Each category carries a human-readable [label] for UI display.
/// Icons are intentionally NOT stored here — they are a presentation
/// concern and are mapped via an extension in the UI layer.
enum CategoryType {
  food('Food & Dining'),
  transport('Transport'),
  shopping('Shopping'),
  bills('Bills & Utilities'),
  entertainment('Entertainment'),
  health('Health'),
  education('Education'),
  salary('Salary'),
  other('Other');

  /// Human-readable label for UI display.
  final String label;

  const CategoryType(this.label);
}
