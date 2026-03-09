import 'package:expense_tracker/domain/entities/account_entity.dart';
import 'package:expense_tracker/domain/repositories/i_account_repository.dart';
import 'package:expense_tracker/data/database/account_dao.dart';
import 'package:expense_tracker/data/models/account_model.dart';
import 'package:uuid/uuid.dart';

class AccountRepository implements IAccountRepository {
  final AccountDao _dao;
  String _activeProfileId = 'default';

  AccountRepository({AccountDao? dao}) : _dao = dao ?? AccountDao();

  @override
  String get activeProfileId => _activeProfileId;

  @override
  void setActiveProfile(String profileId) {
    _activeProfileId = profileId;
  }

  @override
  Future<void> insert(AccountEntity account) async {
    final model = AccountModel.fromEntity(account).copyWith(
      id: account.id.isEmpty ? const Uuid().v4() : account.id,
      profileId: _activeProfileId,
    );
    await _dao.insert(model);
  }

  @override
  Future<void> update(AccountEntity account) async {
    final model = AccountModel.fromEntity(
      account,
    ).copyWith(profileId: _activeProfileId);
    await _dao.update(model);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.delete(id, _activeProfileId);
  }

  @override
  Future<List<AccountEntity>> getByProfileId(String profileId) async {
    final models = await _dao.getByProfileId(profileId);
    final balances = await _dao.getAccountBalances(profileId);

    return models.map((m) {
      final balance = balances[m.id] ?? 0.0;
      return m.toEntity(currentBalance: balance);
    }).toList();
  }

  @override
  Future<AccountEntity?> getById(String id) async {
    final model = await _dao.getById(id);
    if (model == null) return null;

    final balances = await _dao.getAccountBalances(_activeProfileId);
    final balance = balances[id] ?? 0.0;

    return model.toEntity(currentBalance: balance);
  }

  @override
  Future<void> setDefaultAccount(String id) async {
    await _dao.setDefaultAccount(id, _activeProfileId);
  }
}

extension AccountModelCopyWith on AccountModel {
  AccountModel copyWith({
    String? id,
    String? profileId,
    String? name,
    String? type,
    String? icon,
    int? isDefault,
  }) {
    return AccountModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
