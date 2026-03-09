import 'package:expense_tracker/domain/entities/profile_entity.dart';

/// Data model for SQLite serialization of profiles.
class ProfileModel {
  final String id;
  final String name;
  final int isDefault; // SQLite uses 0/1 for booleans
  final String createdAt;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'is_default': isDefault,
    'created_at': createdAt,
  };

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      name: map['name'] as String,
      isDefault: (map['is_default'] as int?) ?? 0,
      createdAt: map['created_at'] as String,
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      name: name,
      isDefault: isDefault == 1,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      name: entity.name,
      isDefault: entity.isDefault ? 1 : 0,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
