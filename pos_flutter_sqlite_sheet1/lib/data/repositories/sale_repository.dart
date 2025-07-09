import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../../config/constants.dart';
import 'database_helper.dart';

class SaleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertSale(Sale sale) async {
    final db = await _dbHelper.database;
    return await db.insert(AppConstants.salesTable, sale.toMap());
  }

  Future<int> insertSaleItem(SaleItem item) async {
    final db = await _dbHelper.database;
    return await db.insert(AppConstants.saleItemsTable, item.toMap());
  }

  Future<List<Sale>> getAllSales() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.salesTable,
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Sale.fromMap(maps[i]));
  }

  Future<Sale?> getSaleById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.salesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Sale.fromMap(maps.first);
  }

  Future<List<SaleItem>> getSaleItems(int saleId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.saleItemsTable,
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
    return List.generate(maps.length, (i) => SaleItem.fromMap(maps[i]));
  }

  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.salesTable,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Sale.fromMap(maps[i]));
  }

  Future<double> getTotalSalesByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total
      FROM ${AppConstants.salesTable}
      WHERE date BETWEEN ? AND ?
    ''', [start.toIso8601String(), end.toIso8601String()]);
    return result.first['total'] as double? ?? 0;
  }

  Future<List<Map<String, dynamic>>> getSalesReport(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        date,
        COUNT(*) as total_sales,
        SUM(total_amount) as total_revenue,
        SUM(discount) as total_discount,
        SUM(tax) as total_tax
      FROM ${AppConstants.salesTable}
      WHERE date BETWEEN ? AND ?
      GROUP BY date
      ORDER BY date DESC
    ''', [start.toIso8601String(), end.toIso8601String()]);
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        si.product_id,
        si.product_name,
        SUM(si.quantity) as total_quantity,
        SUM(si.total) as total_revenue
      FROM ${AppConstants.saleItemsTable} si
      JOIN ${AppConstants.salesTable} s ON si.sale_id = s.id
      WHERE s.date BETWEEN ? AND ?
      GROUP BY si.product_id
      ORDER BY total_quantity DESC
      LIMIT 10
    ''', [start.toIso8601String(), end.toIso8601String()]);
  }

  Future<void> deleteSale(int id) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Delete sale items first
      await txn.delete(
        AppConstants.saleItemsTable,
        where: 'sale_id = ?',
        whereArgs: [id],
      );
      // Then delete the sale
      await txn.delete(
        AppConstants.salesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> updateSaleStatus(int id, String status) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.salesTable,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 