/// Represents the direction of a financial transaction.
///
/// Every transaction is either money coming in ([income])
/// or money going out ([expense]).
enum TransactionType {
  income('Income', 1),
  expense('Expense', -1);

  /// Human-readable label for UI display.
  final String label;

  /// Multiplier for balance calculations:
  /// +1 for income, -1 for expense.
  final int sign;

  const TransactionType(this.label, this.sign);
}
