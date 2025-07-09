import 'package:flutter/foundation.dart';
import '../models/category.dart' as models;
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _repository.getAllCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(models.Category category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _repository.insertCategory(category);
      final newCategory = category.copyWith(id: id);
      _categories.add(newCategory);
      _categories.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(models.Category category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        _categories.sort((a, b) => a.name.compareTo(b.name));
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteCategory(id);
      _categories.removeWhere((category) => category.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<models.Category>> searchCategories(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _repository.searchCategories(query);
      return results;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> getProductCount(int categoryId) async {
    try {
      return await _repository.getProductCount(categoryId);
    } catch (e) {
      _error = e.toString();
      return 0;
    }
  }

  models.Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
} 