class Patient {
  final int? id;
  final String name;
  final String address;
  final String phone;
  final String? imagePath;

  Patient({this.id, required this.name, required this.address, required this.phone, this.imagePath});

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'imagePath': imagePath,
    };
  }
} 