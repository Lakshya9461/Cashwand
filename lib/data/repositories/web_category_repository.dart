import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/data/models/category_model.dart';
import 'package:expense_tracker/domain/entities/category_entity.dart';
import 'package:expense_tracker/domain/repositories/i_category_repository.dart';
import 'package:expense_tracker/domain/enums/category_type.dart';
import 'package:expense_tracker/core/extensions/category_type_extensions.dart';

class WebCategoryRepository implements ICategoryRepository {
  static const String _key = 'expense_tracker_categories';
  String _activeProfileId = 'default';

  @override
  String get activeProfileId => _activeProfileId;

  @override
  void setActiveProfile(String profileId) {
    _activeProfileId = profileId;
  }

  Future<List<CategoryModel>> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null) {
      return _generateDefaultCategories();
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((map) => CategoryModel.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _generateDefaultCategories();
    }
  }

  Future<void> _saveToPrefs(List<CategoryModel> models) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(models.map((m) => m.toMap()).toList());
    await prefs.setString(_key, jsonString);
  }

  List<CategoryModel> _generateDefaultCategories() {
    return CategoryType.values.map((type) {
      return CategoryModel(
        id: type.name,
        profileId: 'default',
        name: type.label,
        icon: type.icon.codePoint.toString(),
        color: type.color
            .toARGB32()
            .toRadixString(16)
            .padLeft(8, '0')
            .toUpperCase(),
        isSystem: 1,
      );
    }).toList();
  }

  @override
  Future<void> insert(CategoryEntity category) async {
    final models = await _loadFromPrefs();

    // Replace if exists
    final index = models.indexWhere((m) => m.id == category.id);
    final newModel = CategoryModel.fromEntity(category);

    if (index >= 0) {
      models[index] = newModel;
    } else {
      models.add(newModel);
    }

    await _saveToPrefs(models);
  }

  @override
  Future<void> update(CategoryEntity category) async {
    await insert(category);
  }

  @override
  Future<void> delete(String id) async {
    final models = await _loadFromPrefs();
    models.removeWhere(
      (m) => m.id == id && m.isSystem == 0 && m.profileId == _activeProfileId,
    );
    await _saveToPrefs(models);
  }

  @override
  Future<CategoryEntity?> getById(String id) async {
    final models = await _loadFromPrefs();
    try {
      final model = models.firstWhere((m) => m.id == id);
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<CategoryEntity>> getByProfileId(String profileId) async {
    final models = await _loadFromPrefs();
    // For MVP web, we might generate default categories per profile on the fly if empty, or just return what we have.
    final profileCategories = models
        .where((m) => m.profileId == profileId)
        .toList();
    if (profileCategories.isEmpty) {
      // Just return defaults scoped to this profile
      return _generateDefaultCategories()
          .map(
            (m) => CategoryModel(
              id: m.id,
              profileId: profileId,
              name: m.name,
              icon: m.icon,
              color: m.color,
              isSystem: m.isSystem,
            ).toEntity(),
          )
          .toList();
    }
    return profileCategories.map((m) => m.toEntity()).toList();
  }
}
