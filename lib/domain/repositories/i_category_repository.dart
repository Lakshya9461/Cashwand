import 'package:expense_tracker/domain/entities/category_entity.dart';

/// Repository interface for custom and system categories.
abstract class ICategoryRepository {
  /// The currently active profile ID for data scoping.
  String get activeProfileId;

  /// Updates the active profile scope.
  void setActiveProfile(String profileId);

  Future<void> insert(CategoryEntity category);
  Future<void> update(CategoryEntity category);
  Future<void> delete(String id);
  Future<List<CategoryEntity>> getByProfileId(String profileId);
  Future<CategoryEntity?> getById(String id);
}
