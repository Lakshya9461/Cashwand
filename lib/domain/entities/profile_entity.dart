/// Domain entity representing a user-created financial profile/space.
///
/// Each profile represents an isolated financial context (e.g. Personal,
/// Household, Business). Transactions belong to exactly one profile.
class ProfileEntity {
  final String id;
  final String name;
  final DateTime createdAt;
  final bool isDefault;

  ProfileEntity({
    required this.id,
    required this.name,
    required this.isDefault,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now() {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Profile name cannot be empty');
    }
    if (name.length > 30) {
      throw ArgumentError.value(
        name,
        'name',
        'Profile name must be 30 characters or less',
      );
    }
  }

  ProfileEntity copyWith({String? name, bool? isDefault}) {
    return ProfileEntity(
      id: id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ProfileEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ProfileEntity(id: $id, name: $name, isDefault: $isDefault)';
}
