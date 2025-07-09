class AppConstants {
  // App Info
  static const String appName = 'Smart POS System';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'pos_database.db';
  
  // Table Names
  static const String categoriesTable = 'categories';
  static const String productsTable = 'products';
  static const String salesTable = 'sales';
  static const String saleItemsTable = 'sale_items';
  
  // Stock Levels
  static const int criticalStockThreshold = 2;
  static const int lowStockThreshold = 5;
  static const int mediumStockThreshold = 10;
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  // Currency
  static const String currencySymbol = '\$';
  
  // File Extensions
  static const List<String> allowedFileExtensions = ['csv', 'xlsx', 'xls'];

  // Shared Preferences Keys
  static const String prefUserLoggedIn = 'user_logged_in';
  static const String prefUserRole = 'user_role';
  static const String prefLastSyncTime = 'last_sync_time';

  // Google Sheets
  static const String spreadsheetId = ''; // To be filled with your Google Sheet ID
  static const String productsSheetName = 'Products';
  static const String salesSheetName = 'Sales';
} 