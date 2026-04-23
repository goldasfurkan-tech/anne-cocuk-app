import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String id;
  final String name;
  final String surname;
  final String gender; // 'male' veya 'female'
  final DateTime dateOfBirth;

  ChildModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.gender,
    required this.dateOfBirth,
  });

  // Yaş hesaplama
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Ay cinsinden yaş (1 yaşından küçükler için)
  int get ageInMonths {
    final now = DateTime.now();
    return (now.year - dateOfBirth.year) * 12 + (now.month - dateOfBirth.month);
  }

  // Harita badge'i için yaş etiketi
  String get ageLabel {
    final months = ageInMonths;
    if (months < 12) return '${months}a';
    return '${age}y';
  }

  factory ChildModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChildModel(
      id: doc.id,
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      gender: data['gender'] ?? 'male',
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'surname': surname,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
    };
  }

  ChildModel copyWith({
    String? name,
    String? surname,
    String? gender,
    DateTime? dateOfBirth,
  }) {
    return ChildModel(
      id: id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
