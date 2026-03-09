import 'package:expense_tracker/domain/entities/category_entity.dart';
import 'package:expense_tracker/domain/repositories/i_category_repository.dart';
import 'package:expense_tracker/data/database/category_dao.dart';
import 'package:expense_tracker/data/models/category_model.dart';
import 'package:uuid/uuid.dart';

class CategoryRepository implements ICategoryRepository {
  final CategoryDao _dao;
  String _activeProfileId = 'default';

  CategoryRepository({CategoryDao? dao}) : _dao = dao ?? CategoryDao();

  @override
  String get activeProfileId => _activeProfileId;

  @override
  void setActiveProfile(String profileId) {
    _activeProfileId = profileId;
  }

  @override
  Future<void> insert(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category).copyWith(
      id: category.id.isEmpty ? const Uuid().v4() : category.id,
      profileId: _activeProfileId,
    );
    await _dao.insert(model);
  }

  @override
  Future<void> update(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(
      category,
    ).copyWith(profileId: _activeProfileId);
    await _dao.update(model);
  }

  @override
  Future<void> delete(String id) async {
    await _dao.delete(id, _activeProfileId);
  }

  @override
  Future<List<CategoryEntity>> getByProfileId(String profileId) async {
    final models = await _dao.getByProfileId(profileId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CategoryEntity?> getById(String id) async {
    final model = await _dao.getById(id);
    return model?.toEntity();
  }
}

// Extension to patch `copyWith` since I used it above
extension CategoryModelCopyWith on CategoryModel {
  CategoryModel copyWith({
    String? id,
    String? profileId,
    String? name,
    String? icon,
    String? color,
    int? isSystem,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isSystem: isSystem ?? this.isSystem,
    );
  }
}
