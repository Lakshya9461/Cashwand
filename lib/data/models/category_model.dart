import 'package:expense_tracker/domain/entities/category_entity.dart';

class CategoryModel {
  final String id;
  final String profileId;
  final String name;
  final String icon;
  final String color;
  final int isSystem;

  const CategoryModel({
    required this.id,
    required this.profileId,
    required this.name,
    required this.icon,
    required this.color,
    required this.isSystem,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'name': name,
      'icon': icon,
      'color': color,
      'is_system': isSystem,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
      isSystem: map['is_system'] as int,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      profileId: profileId,
      name: name,
      icon: icon,
      color: color,
      isSystem: isSystem == 1,
    );
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      profileId: entity.profileId,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      isSystem: entity.isSystem ? 1 : 0,
    );
  }
}
