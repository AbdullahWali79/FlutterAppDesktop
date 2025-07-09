import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import '../../config/constants.dart';
import 'database_helper.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertProduct(Product product) async {
    final db = await _dbHelper.database;
    return await db.insert(AppConstants.productsTable, product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.productsTable,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product?> getProductById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.productsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.productsTable,
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.productsTable,
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<int> updateProduct(Product product) async {
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.productsTable,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.productsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateStockQuantity(int productId, int quantity) async {
    final db = await _dbHelper.database;
    return await db.rawUpdate('''
      UPDATE ${AppConstants.productsTable}
      SET stock_quantity = stock_quantity + ?
      WHERE id = ?
    ''', [quantity, productId]);
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.productsTable,
      where: 'name LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }
} 