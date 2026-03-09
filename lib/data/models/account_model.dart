import 'package:expense_tracker/domain/entities/account_entity.dart';

class AccountModel {
  final String id;
  final String profileId;
  final String name;
  final String type;
  final String icon;
  final int isDefault;

  const AccountModel({
    required this.id,
    required this.profileId,
    required this.name,
    required this.type,
    required this.icon,
    required this.isDefault,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'name': name,
      'type': type,
      'icon': icon,
      'is_default': isDefault,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as String,
      isDefault: map['is_default'] as int,
    );
  }

  AccountEntity toEntity({double currentBalance = 0.0}) {
    return AccountEntity(
      id: id,
      profileId: profileId,
      name: name,
      type: type,
      icon: icon,
      isDefault: isDefault == 1,
      currentBalance: currentBalance,
    );
  }

  factory AccountModel.fromEntity(AccountEntity entity) {
    return AccountModel(
      id: entity.id,
      profileId: entity.profileId,
      name: entity.name,
      type: entity.type,
      icon: entity.icon,
      isDefault: entity.isDefault ? 1 : 0,
    );
  }
}
