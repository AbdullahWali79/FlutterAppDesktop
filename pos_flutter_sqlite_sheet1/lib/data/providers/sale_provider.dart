import 'package:flutter/foundation.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../repositories/sale_repository.dart';

class SaleProvider with ChangeNotifier {
  final SaleRepository _repository = SaleRepository();
  List<Sale> _sales = [];
  List<SaleItem> _currentSaleItems = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Sale> get sales => _sales;
  List<SaleItem> get currentSaleItems => _currentSaleItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all sales
  Future<void> loadSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sales = await _repository.getAllSales();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new sale
  Future<void> createSale(Sale sale, List<SaleItem> items) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final saleId = await _repository.insertSale(sale);
      
      // Insert all sale items
      for (var item in items) {
        await _repository.insertSaleItem(
          item.copyWith(saleId: saleId),
        );
      }

      // Reload sales to get the updated list
      await loadSales();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get sale items for a specific sale
  Future<void> loadSaleItems(int saleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentSaleItems = await _repository.getSaleItems(saleId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get sales by date range
  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    try {
      return await _repository.getSalesByDateRange(start, end);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get total sales for a date range
  Future<double> getTotalSalesByDateRange(DateTime start, DateTime end) async {
    try {
      return await _repository.getTotalSalesByDateRange(start, end);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0;
    }
  }

  // Get sales report
  Future<List<Map<String, dynamic>>> getSalesReport(DateTime start, DateTime end) async {
    try {
      return await _repository.getSalesReport(start, end);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get top selling products
  Future<List<Map<String, dynamic>>> getTopSellingProducts(DateTime start, DateTime end) async {
    try {
      return await _repository.getTopSellingProducts(start, end);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Delete a sale
  Future<void> deleteSale(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteSale(id);
      await loadSales(); // Reload the sales list
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update sale status
  Future<void> updateSaleStatus(int id, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateSaleStatus(id, status);
      await loadSales(); // Reload the sales list
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear current sale items
  void clearCurrentSaleItems() {
    _currentSaleItems = [];
    notifyListeners();
  }
} 