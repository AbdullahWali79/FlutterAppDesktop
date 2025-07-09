import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../services/database_service.dart';
import '../services/sheets_service.dart';

class AppState extends ChangeNotifier {
  List<Product> _products = [];
  List<Customer> _customers = [];
  List<Sale> _sales = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get products => _products;
  List<Customer> get customers => _customers;
  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize app state
  Future<void> init() async {
    await loadProducts();
    await loadCustomers();
    await loadSales();
  }

  // Product operations
  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      _products = await DatabaseService.getProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> syncProducts() async {
    _setLoading(true);
    try {
      final sheetsProducts = await SheetsService.getProducts();
      for (var product in sheetsProducts) {
        await DatabaseService.addProduct(product);
      }
      await loadProducts();
      _error = null;
    } catch (e) {
      _error = 'Failed to sync products: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProductStock(String id, int newStock) async {
    _setLoading(true);
    try {
      await DatabaseService.updateProductStock(id, newStock);
      await SheetsService.updateProductStock(id, newStock);
      await loadProducts();
      _error = null;
    } catch (e) {
      _error = 'Failed to update product stock: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Customer operations
  Future<void> loadCustomers() async {
    _setLoading(true);
    try {
      _customers = await DatabaseService.getAllCustomers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    _setLoading(true);
    try {
      await DatabaseService.insertCustomer(customer);
      await loadCustomers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Sale operations
  Future<void> loadSales() async {
    _setLoading(true);
    try {
      _sales = await DatabaseService.getAllSales();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  Future<void> addSale(Sale sale) async {
    _setLoading(true);
    try {
      await DatabaseService.insertSale(sale);
      // Update product stock
      for (var item in sale.items) {
        final product = _products.firstWhere((p) => p.id == item.productId);
        await updateProductStock(product.id, product.stock - item.quantity);
      }
      await loadSales();
      _error = null;
    } catch (e) {
      _error = 'Failed to add sale: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
} 