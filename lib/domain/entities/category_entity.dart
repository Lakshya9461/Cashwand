/// Domain entity representing a custom or system category.
class CategoryEntity {
  final String id;
  final String profileId;
  final String name;
  final String icon; // IconData codePoint point or specific identifier
  final String color; // Hex string, e.g., '0xFF00FF00'
  final bool isSystem;

  CategoryEntity({
    required this.id,
    required this.profileId,
    required this.name,
    required this.icon,
    required this.color,
    this.isSystem = false,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('Category name cannot be empty');
    }
    if (name.length > 30) {
      throw ArgumentError('Category name must be 30 characters or less');
    }
  }

  CategoryEntity copyWith({
    String? id,
    String? profileId,
    String? name,
    String? icon,
    String? color,
    bool? isSystem,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CategoryEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
