import 'package:flutter/foundation.dart';
import 'package:expense_tracker/domain/entities/category_entity.dart';
import 'package:expense_tracker/domain/repositories/i_category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final ICategoryRepository _repository;

  CategoryProvider(this._repository);

  List<CategoryEntity> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryEntity> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _repository.getByProfileId(
        _repository.activeProfileId,
      );
    } catch (e, st) {
      _error = 'Failed to load categories: $e';
      debugPrint('Category load error: $e\\n$st');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(CategoryEntity category) async {
    try {
      await _repository.insert(category);
      await loadCategories();
    } catch (e) {
      _error = 'Failed to add category: $e';
      notifyListeners();
    }
  }

  Future<void> updateCategory(CategoryEntity category) async {
    try {
      await _repository.update(category);
      await loadCategories();
    } catch (e) {
      _error = 'Failed to update category: $e';
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.delete(id);
      await loadCategories();
    } catch (e) {
      _error = 'Failed to delete category: $e';
      notifyListeners();
    }
  }

  CategoryEntity? getById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
