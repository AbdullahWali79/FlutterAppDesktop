import 'customer.dart';

class Sale {
  final int? id;
  final DateTime timestamp;
  final List<SaleItem> items;
  final Customer? customer;
  final double totalAmount;

  Sale({
    this.id,
    DateTime? timestamp,
    required this.items,
    this.customer,
    required this.totalAmount,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      items: (map['items'] as List)
          .map((item) => SaleItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      customer: map['customer'] != null
          ? Customer.fromMap(map['customer'] as Map<String, dynamic>)
          : null,
      totalAmount: (map['total_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'customer': customer?.toMap(),
      'total_amount': totalAmount,
    };
  }
}

class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      totalPrice: (map['total_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
} 