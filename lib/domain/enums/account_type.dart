/// Source accounts for income transactions.
///
/// Tracks WHERE the money came from. Each account carries
/// a human-readable [label] for UI display.
/// Icons are mapped in the presentation layer via extensions.
enum AccountType {
  salary('Salary Account'),
  cash('Cash'),
  bank('Bank Account'),
  freelance('Freelance'),
  business('Business'),
  other('Other');

  /// Human-readable label for UI display.
  final String label;

  const AccountType(this.label);
}
