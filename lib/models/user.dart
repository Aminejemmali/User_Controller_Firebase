import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String name;
  String avatarUrl;
  String phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.phoneNumber,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.id,
      name: doc['name'],
      avatarUrl: doc['avatarUrl'],
      phoneNumber: doc['phoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
    };
  }
}
