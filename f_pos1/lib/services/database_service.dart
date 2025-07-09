import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'pos_database.db';
  static const String _tableName = 'products';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    final databaseFactory = databaseFactoryFfi;
    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ),
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE $_tableName(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Sales table
    await db.execute('''
      CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        customer_id INTEGER,
        total_amount REAL NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    // Sale items table
    await db.execute('''
      CREATE TABLE sale_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
  }

  // Product operations
  static Future<void> addProduct(Product product) async {
    final db = await database;
    await db.insert(
      _tableName,
      {
        'id': product.id,
        'name': product.name,
        'category': product.category,
        'price': product.price,
        'stock': product.stock,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'],
        name: maps[i]['name'],
        category: maps[i]['category'],
        price: maps[i]['price'],
        stock: maps[i]['stock'],
      );
    });
  }

  static Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      _tableName,
      {
        'name': product.name,
        'category': product.category,
        'price': product.price,
        'stock': product.stock,
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  static Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateProductStock(String id, int newStock) async {
    final db = await database;
    await db.update(
      _tableName,
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Customer operations
  static Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  static Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  // Sale operations
  static Future<int> insertSale(Sale sale) async {
    final db = await database;
    final batch = db.batch();

    // Insert sale
    final saleId = await db.insert('sales', {
      'timestamp': sale.timestamp.toIso8601String(),
      'customer_id': sale.customer?.id,
      'total_amount': sale.totalAmount,
    });

    // Insert sale items
    for (var item in sale.items) {
      await db.insert('sale_items', {
        'sale_id': saleId,
        'product_id': item.productId,
        'product_name': item.productName,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'total_price': item.totalPrice,
      });
    }

    await batch.commit();
    return saleId;
  }

  static Future<List<Sale>> getAllSales() async {
    final db = await database;
    final List<Map<String, dynamic>> saleMaps = await db.query('sales');
    final List<Sale> sales = [];

    for (var saleMap in saleMaps) {
      final saleId = saleMap['id'] as int;
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'sale_items',
        where: 'sale_id = ?',
        whereArgs: [saleId],
      );

      final items = itemMaps.map((map) => SaleItem.fromMap(map)).toList();
      Customer? customer;
      if (saleMap['customer_id'] != null) {
        final customerMap = await db.query(
          'customers',
          where: 'id = ?',
          whereArgs: [saleMap['customer_id']],
        );
        if (customerMap.isNotEmpty) {
          customer = Customer.fromMap(customerMap.first);
        }
      }

      sales.add(Sale(
        id: saleId,
        timestamp: DateTime.parse(saleMap['timestamp'] as String),
        items: items,
        customer: customer,
        totalAmount: saleMap['total_amount'] as double,
      ));
    }

    return sales;
  }
} 