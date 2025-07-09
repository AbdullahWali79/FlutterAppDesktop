class Customer {
  final int? id;
  final String name;
  final String phone;
  final DateTime createdAt;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 