import 'package:expense_tracker/domain/entities/transaction_entity.dart';

/// Contract for transaction data operations.
///
/// This abstract class defines the boundary between the domain and data
/// layers. The domain layer depends on this interface; the data layer
/// implements it. This inversion ensures the domain stays pure and
/// testable — it never knows about SQLite, JSON, or any storage detail.
///
/// ## Retrieval Strategy
///
/// All query methods return **`Future<List<>>`** rather than `Stream`.
///
/// **Why not Streams?**
/// - SQLite queries are one-shot reads, not continuous listeners.
/// - Reactive UI updates are handled by [ChangeNotifier] in the Provider
///   layer, which calls `notifyListeners()` after mutations.
/// - Streams add lifecycle complexity (open/close/dispose) that isn't
///   justified for MVP scope.
/// - If real-time sync is added later (e.g., Firebase), a `watch` method
///   returning `Stream` can be added without breaking existing code.
///
/// ## Error Handling Philosophy
///
/// - **Validation errors** are caught at entity construction time
///   ([ArgumentError]) — before data ever reaches the repository.
/// - **Storage errors** (disk full, corrupt DB) are infrastructure
///   concerns. They propagate as exceptions from the data layer and
///   are caught in the presentation layer (Provider → UI error state).
/// - This interface does **not** define custom exception types. For MVP,
///   Dart's built-in exceptions are sufficient. Custom error types
///   can be introduced when error granularity becomes a real need.
///
/// ## Ordering
///
/// Unless otherwise noted, list results are ordered by [date] descending
/// (newest first), which matches the transaction history UI.
abstract class ITransactionRepository {
  /// The currently active profile ID for data scoping.
  String get activeProfileId;

  /// Updates the active profile scope for all subsequent operations.
  void setActiveProfile(String profileId);

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  /// Persists a new transaction.
  ///
  /// The [transaction] entity must have a unique [id]. If a transaction
  /// with the same id already exists, the behavior is implementation-defined
  /// (typically throws or silently replaces — see data layer docs).
  Future<void> insert(TransactionEntity transaction);

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Returns all transactions, newest first.
  Future<List<TransactionEntity>> getAll();

  /// Returns a single transaction by [id], or `null` if not found.
  Future<TransactionEntity?> getById(String id);

  /// Returns transactions within the given date range (inclusive).
  ///
  /// Both [start] and [end] are inclusive. Results are newest first.
  Future<List<TransactionEntity>> getByDateRange(DateTime start, DateTime end);

  Future<List<TransactionEntity>> getByCategory(String categoryId);

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  /// Replaces an existing transaction with the updated [transaction].
  ///
  /// Matches by [transaction.id]. If no matching record exists,
  /// the behavior is implementation-defined (typically a no-op or throws).
  Future<void> update(TransactionEntity transaction);

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  /// Removes the transaction with the given [id].
  ///
  /// If no matching record exists, this is a silent no-op.
  Future<void> delete(String id);

  /// Deletes all transactions.
  Future<void> deleteAll();

  // ---------------------------------------------------------------------------
  // Aggregation
  // ---------------------------------------------------------------------------

  /// Returns the total income and expense for a given month.
  ///
  /// The returned map has exactly two keys:
  /// - `'income'`  → total income as a positive double
  /// - `'expense'` → total expenses as a positive double
  ///
  /// If there are no transactions for the given month, both values are `0.0`.
  ///
  /// This is a domain-level query because "monthly financial position"
  /// is a core business concept (see PRD goals G2, G4).
  Future<Map<String, double>> getMonthlySummary(int year, int month);
}
