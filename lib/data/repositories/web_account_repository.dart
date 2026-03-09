import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/data/models/account_model.dart';
import 'package:expense_tracker/domain/entities/account_entity.dart';
import 'package:expense_tracker/domain/repositories/i_account_repository.dart';
import 'package:expense_tracker/domain/enums/account_type.dart';
import 'package:expense_tracker/core/extensions/account_type_extensions.dart';

class WebAccountRepository implements IAccountRepository {
  static const String _key = 'expense_tracker_accounts';
  String _activeProfileId = 'default';

  @override
  String get activeProfileId => _activeProfileId;

  @override
  void setActiveProfile(String profileId) {
    _activeProfileId = profileId;
  }

  Future<List<AccountModel>> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null) {
      return _generateDefaultAccounts();
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((map) => AccountModel.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _generateDefaultAccounts();
    }
  }

  Future<void> _saveToPrefs(List<AccountModel> models) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(models.map((m) => m.toMap()).toList());
    await prefs.setString(_key, jsonString);
  }

  List<AccountModel> _generateDefaultAccounts() {
    return AccountType.values.map((type) {
      return AccountModel(
        id: type.name,
        profileId: 'default',
        name: type.label,
        type: 'bank',
        icon: type.icon.codePoint.toString(),
        isDefault: type == AccountType.bank ? 1 : 0,
      );
    }).toList();
  }

  @override
  Future<void> insert(AccountEntity account) async {
    final models = await _loadFromPrefs();

    // Clear default if needed
    if (account.isDefault) {
      for (int i = 0; i < models.length; i++) {
        if (models[i].profileId == _activeProfileId &&
            models[i].isDefault == 1) {
          models[i] = AccountModel(
            id: models[i].id,
            profileId: models[i].profileId,
            name: models[i].name,
            type: models[i].type,
            icon: models[i].icon,
            isDefault: 0,
          );
        }
      }
    }

    final index = models.indexWhere((m) => m.id == account.id);
    final newModel = AccountModel.fromEntity(account);

    if (index >= 0) {
      models[index] = newModel;
    } else {
      models.add(newModel);
    }

    await _saveToPrefs(models);
  }

  @override
  Future<void> update(AccountEntity account) async {
    await insert(account);
  }

  @override
  Future<void> delete(String id) async {
    final models = await _loadFromPrefs();
    models.removeWhere((m) => m.id == id && m.profileId == _activeProfileId);

    // If we deleted the default, set another to default
    final profileModels = models
        .where((m) => m.profileId == _activeProfileId)
        .toList();
    if (profileModels.isNotEmpty &&
        !profileModels.any((m) => m.isDefault == 1)) {
      final newDefault = AccountModel(
        id: profileModels.first.id,
        profileId: profileModels.first.profileId,
        name: profileModels.first.name,
        type: profileModels.first.type,
        icon: profileModels.first.icon,
        isDefault: 1,
      );
      final index = models.indexWhere((m) => m.id == newDefault.id);
      if (index >= 0) {
        models[index] = newDefault;
      }
    }

    await _saveToPrefs(models);
  }

  @override
  Future<AccountEntity?> getById(String id) async {
    final models = await _loadFromPrefs();
    try {
      final model = models.firstWhere((m) => m.id == id);
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setDefaultAccount(String id) async {
    final models = await _loadFromPrefs();
    for (int i = 0; i < models.length; i++) {
      if (models[i].profileId == _activeProfileId) {
        models[i] = AccountModel(
          id: models[i].id,
          profileId: models[i].profileId,
          name: models[i].name,
          type: models[i].type,
          icon: models[i].icon,
          isDefault: models[i].id == id ? 1 : 0,
        );
      }
    }
    await _saveToPrefs(models);
  }

  @override
  Future<List<AccountEntity>> getByProfileId(String profileId) async {
    final models = await _loadFromPrefs();
    final profileAccounts = models
        .where((m) => m.profileId == profileId)
        .toList();
    if (profileAccounts.isEmpty) {
      return _generateDefaultAccounts()
          .map(
            (m) => AccountModel(
              id: m.id,
              profileId: profileId,
              name: m.name,
              type: m.type,
              icon: m.icon,
              isDefault: m.isDefault,
            ).toEntity(),
          )
          .toList();
    }
    return profileAccounts.map((m) => m.toEntity()).toList();
  }
}
