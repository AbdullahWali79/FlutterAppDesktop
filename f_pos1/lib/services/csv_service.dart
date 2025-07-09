import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../models/product.dart';

class CSVService {
  static const String _fileName = 'products.csv';
  static const List<String> _headers = ['ID', 'Name', 'Category', 'Price', 'Stock'];

  // Create and download template CSV
  static Future<String> createTemplate() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_fileName');
    
    // Create CSV content with headers
    final csvData = [
      _headers,
    ];
    
    final csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);
    
    return file.path;
  }

  // Import products from CSV
  static Future<List<Product>> importProducts(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found');
    }

    final csvString = await file.readAsString();
    final csvTable = const CsvToListConverter().convert(csvString);

    // Skip header row
    return csvTable.skip(1).map((row) {
      return Product(
        id: row[0].toString(),
        name: row[1].toString(),
        category: row[2].toString(),
        price: double.parse(row[3].toString()),
        stock: int.parse(row[4].toString()),
      );
    }).toList();
  }

  // Export products to CSV
  static Future<String> exportProducts(List<Product> products) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_fileName');
    
    // Create CSV content
    final csvData = [
      _headers,
      ...products.map((product) => [
        product.id,
        product.name,
        product.category,
        product.price.toString(),
        product.stock.toString(),
      ]),
    ];
    
    final csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);
    
    return file.path;
  }
} 