class Visit {
  final int? id;
  final int patientId;
  final String diagnosis;
  final String comments;
  final DateTime dateTime;
  final String? imagePath;

  Visit({this.id, required this.patientId, required this.diagnosis, required this.comments, required this.dateTime, this.imagePath});

  factory Visit.fromMap(Map<String, dynamic> map) {
    return Visit(
      id: map['id'],
      patientId: map['patientId'],
      diagnosis: map['diagnosis'],
      comments: map['comments'],
      dateTime: DateTime.parse(map['dateTime']),
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'diagnosis': diagnosis,
      'comments': comments,
      'dateTime': dateTime.toIso8601String(),
      'imagePath': imagePath,
    };
  }
} 