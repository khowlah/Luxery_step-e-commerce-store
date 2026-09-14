import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;

  UserProfile({
    required this.uid,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}
