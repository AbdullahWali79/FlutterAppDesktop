import 'package:flutter/foundation.dart';

class Sale {
  final int? id;
  final DateTime date;
  final double totalAmount;
  final double discount;
  final double tax;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final String paymentMethod;
  final String status;

  Sale({
    this.id,
    required this.date,
    required this.totalAmount,
    this.discount = 0,
    this.tax = 0,
    this.customerName,
    this.customerPhone,
    this.notes,
    required this.paymentMethod,
    this.status = 'completed',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'total_amount': totalAmount,
      'discount': discount,
      'tax': tax,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'notes': notes,
      'payment_method': paymentMethod,
      'status': status,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int,
      date: DateTime.parse(map['date'] as String),
      totalAmount: map['total_amount'] as double,
      discount: map['discount'] as double,
      tax: map['tax'] as double,
      customerName: map['customer_name'] as String?,
      customerPhone: map['customer_phone'] as String?,
      notes: map['notes'] as String?,
      paymentMethod: map['payment_method'] as String,
      status: map['status'] as String,
    );
  }

  Sale copyWith({
    int? id,
    DateTime? date,
    double? totalAmount,
    double? discount,
    double? tax,
    String? customerName,
    String? customerPhone,
    String? notes,
    String? paymentMethod,
    String? status,
  }) {
    return Sale(
      id: id ?? this.id,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
    );
  }
} 