import 'package:flutter/foundation.dart';

class SaleItem {
  final int? id;
  final int saleId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double discount;
  final double total;

  SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.discount = 0,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'discount': discount,
      'total': total,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'] as int,
      saleId: map['sale_id'] as int,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      price: map['price'] as double,
      quantity: map['quantity'] as int,
      discount: map['discount'] as double,
      total: map['total'] as double,
    );
  }

  SaleItem copyWith({
    int? id,
    int? saleId,
    int? productId,
    String? productName,
    double? price,
    int? quantity,
    double? discount,
    double? total,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      total: total ?? this.total,
    );
  }
} 