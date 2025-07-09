import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import '../../config/constants.dart';
import 'database_helper.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertCategory(Category category) async {
    final db = await _dbHelper.database;
    return await db.insert(AppConstants.categoriesTable, category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.categoriesTable,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.categoriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCategory(Category category) async {
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.categoriesTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    // Check if category has products
    final List<Map<String, dynamic>> products = await db.query(
      AppConstants.productsTable,
      where: 'category_id = ?',
      whereArgs: [id],
    );
    if (products.isNotEmpty) {
      throw Exception('Cannot delete category with associated products');
    }
    return await db.delete(
      AppConstants.categoriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Category>> searchCategories(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.categoriesTable,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> getProductCount(int categoryId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM ${AppConstants.productsTable}
      WHERE category_id = ?
    ''', [categoryId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
} 