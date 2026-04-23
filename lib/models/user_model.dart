import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String surname;
  final String phone;
  final String? photoBase64;
  final DateTime? dateOfBirth;
  final String? city;
  final String? district;
  final String? neighborhood;
  final bool ghostMode;
  final int jetons;
  final List<String> interests;
  final DateTime createdAt;
  final bool profileCompleted;

  UserModel({
    required this.uid,
    required this.name,
    required this.surname,
    required this.phone,
    this.photoBase64,
    this.dateOfBirth,
    this.city,
    this.district,
    this.neighborhood,
    this.ghostMode = false,
    this.jetons = 0,
    this.interests = const [],
    required this.createdAt,
    this.profileCompleted = false,
  });

  // Firestore'dan okuma
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      phone: data['phone'] ?? '',
      photoBase64: data['photoBase64'],
      dateOfBirth: data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      city: data['city'],
      district: data['district'],
      neighborhood: data['neighborhood'],
      ghostMode: data['ghostMode'] ?? false,
      jetons: data['jetons'] ?? 0,
      interests: List<String>.from(data['interests'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      profileCompleted: data['profileCompleted'] ?? false,
    );
  }

  // Firestore'a yazma
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'surname': surname,
      'phone': phone,
      'photoBase64': photoBase64,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'city': city,
      'district': district,
      'neighborhood': neighborhood,
      'ghostMode': ghostMode,
      'jetons': jetons,
      'interests': interests,
      'createdAt': Timestamp.fromDate(createdAt),
      'profileCompleted': profileCompleted,
    };
  }

  // Güncelleme için kopyalama
  UserModel copyWith({
    String? name,
    String? surname,
    String? phone,
    String? photoBase64,
    DateTime? dateOfBirth,
    String? city,
    String? district,
    String? neighborhood,
    bool? ghostMode,
    int? jetons,
    List<String>? interests,
    bool? profileCompleted,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
      photoBase64: photoBase64 ?? this.photoBase64,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      city: city ?? this.city,
      district: district ?? this.district,
      neighborhood: neighborhood ?? this.neighborhood,
      ghostMode: ghostMode ?? this.ghostMode,
      jetons: jetons ?? this.jetons,
      interests: interests ?? this.interests,
      createdAt: createdAt,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }
}
