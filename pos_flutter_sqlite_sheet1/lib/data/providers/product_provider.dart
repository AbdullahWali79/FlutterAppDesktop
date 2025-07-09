import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repository.getAllProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.insertProduct(product);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateProduct(product);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repository.searchProducts(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStock(int productId, int quantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateStockQuantity(productId, quantity);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> getProductById(int id) async {
    try {
      return await _repository.getProductById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      return await _repository.getProductByBarcode(barcode);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      return await _repository.getProductsByCategory(categoryId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }
} 