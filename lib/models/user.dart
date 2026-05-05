import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final double balance;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.balance,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      balance: (data['balance'] as num? ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'balance': balance,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    double? balance,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
