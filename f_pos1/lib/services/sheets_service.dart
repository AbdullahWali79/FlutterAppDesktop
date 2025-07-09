import 'package:gsheets/gsheets.dart';
import '../models/product.dart';

class SheetsService {
  static const String _credentials = '''
    {
      // Add your Google Sheets API credentials here
    }
  ''';

  static const String _spreadsheetId = 'YOUR_SPREADSHEET_ID';
  static const String _worksheetTitle = 'Products';

  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  static Future<String> createNewSpreadsheet() async {
    try {
      final spreadsheet = await _gsheets.createSpreadsheet('POS Products');
      final worksheet = await _getWorkSheet(spreadsheet, title: _worksheetTitle);
      
      // Add headers
      await worksheet.values.insertRow(1, [
        'ID',
        'Name',
        'Category',
        'Price',
        'Stock',
      ]);

      return spreadsheet.id!;
    } catch (e) {
      print('Error creating spreadsheet: $e');
      rethrow;
    }
  }

  static Future<void> init() async {
    try {
      final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
      _worksheet = await _getWorkSheet(spreadsheet, title: _worksheetTitle);
    } catch (e) {
      print('Error initializing Google Sheets: $e');
      rethrow;
    }
  }

  static Future<Worksheet> _getWorkSheet(
    Spreadsheet spreadsheet, {
    required String title,
  }) async {
    try {
      return await spreadsheet.addWorksheet(title);
    } catch (e) {
      return spreadsheet.worksheetByTitle(title)!;
    }
  }

  static Future<List<Product>> getProducts() async {
    if (_worksheet == null) await init();

    final rows = await _worksheet!.values.allRows();
    if (rows.isEmpty) return [];

    // Skip header row
    return rows.skip(1).map((row) {
      return Product(
        id: row[0],
        name: row[1],
        category: row[2],
        price: double.parse(row[3]),
        stock: int.parse(row[4]),
      );
    }).toList();
  }

  static Future<void> updateProductStock(String productId, int newStock) async {
    if (_worksheet == null) await init();

    final rows = await _worksheet!.values.allRows();
    for (var i = 1; i < rows.length; i++) {
      if (rows[i][0] == productId) {
        await _worksheet!.values.insertValue(
          newStock.toString(),
          column: 5,
          row: i + 1,
        );
        break;
      }
    }
  }

  static Future<void> addProduct(Product product) async {
    if (_worksheet == null) await init();

    await _worksheet!.values.appendRow([
      product.id,
      product.name,
      product.category,
      product.price.toString(),
      product.stock.toString(),
    ]);
  }

  static Future<void> updateProduct(Product product) async {
    if (_worksheet == null) await init();

    final rows = await _worksheet!.values.allRows();
    for (var i = 1; i < rows.length; i++) {
      if (rows[i][0] == product.id) {
        await _worksheet!.values.insertRow(i + 1, [
          product.id,
          product.name,
          product.category,
          product.price.toString(),
          product.stock.toString(),
        ]);
        break;
      }
    }
  }
} 