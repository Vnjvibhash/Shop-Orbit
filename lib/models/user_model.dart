import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profileImage;
  final List<String> addresses;
  final bool isBlocked;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    required this.addresses,
    required this.isBlocked,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
  });

  // This method converts the Firestore data into a UserModel object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      profileImage: json['profileImage'],
      addresses: List<String>.from(json['addresses'] ?? []),
      isBlocked: json['isBlocked'] ?? false,
      isApproved: json['isApproved'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  // --- THIS IS THE METHOD TO FIX ---
  // This method converts the UserModel object into a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profileImage': profileImage,
      'addresses': addresses,
      'isBlocked': isBlocked,
      'isApproved': isApproved,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
