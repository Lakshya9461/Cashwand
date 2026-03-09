import 'package:flutter/foundation.dart';
import 'package:expense_tracker/domain/entities/account_entity.dart';
import 'package:expense_tracker/domain/repositories/i_account_repository.dart';

class AccountProvider extends ChangeNotifier {
  final IAccountRepository _repository;

  AccountProvider(this._repository);

  List<AccountEntity> _accounts = [];
  bool _isLoading = false;
  String? _error;

  List<AccountEntity> get accounts => List.unmodifiable(_accounts);
  bool get isLoading => _isLoading;
  String? get error => _error;

  AccountEntity? get defaultAccount {
    try {
      return _accounts.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _accounts.isNotEmpty ? _accounts.first : null;
    }
  }

  Future<void> loadAccounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _accounts = await _repository.getByProfileId(_repository.activeProfileId);
    } catch (e) {
      _error = 'Failed to load accounts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAccount(AccountEntity account) async {
    try {
      await _repository.insert(account);
      await loadAccounts();
    } catch (e) {
      _error = 'Failed to add account: $e';
      notifyListeners();
    }
  }

  Future<void> updateAccount(AccountEntity account) async {
    try {
      await _repository.update(account);
      await loadAccounts();
    } catch (e) {
      _error = 'Failed to update account: $e';
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      await _repository.delete(id);
      await loadAccounts();
    } catch (e) {
      _error = 'Failed to delete account: $e';
      notifyListeners();
    }
  }

  Future<void> setDefaultAccount(String id) async {
    try {
      await _repository.setDefaultAccount(id);
      await loadAccounts();
    } catch (e) {
      _error = 'Failed to set default account: $e';
      notifyListeners();
    }
  }

  AccountEntity? getById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
