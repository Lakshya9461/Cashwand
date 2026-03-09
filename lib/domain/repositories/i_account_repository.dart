import 'package:expense_tracker/domain/entities/account_entity.dart';

/// Repository interface for profiles' accounts.
abstract class IAccountRepository {
  /// The currently active profile ID for data scoping.
  String get activeProfileId;

  /// Updates the active profile scope.
  void setActiveProfile(String profileId);

  Future<void> insert(AccountEntity account);
  Future<void> update(AccountEntity account);
  Future<void> delete(String id);
  Future<List<AccountEntity>> getByProfileId(String profileId);
  Future<AccountEntity?> getById(String id);
  Future<void> setDefaultAccount(String id);
}
