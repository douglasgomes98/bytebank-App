import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_user.dart';

/// Data Transfer Object correspondente ao documento do usuário no Firestore.
///
/// Mantém o conhecimento sobre o formato remoto isolado da camada de
/// domínio. Conta com `fromMap`/`toMap`, [fromFirestore] e
/// [toEntity]/[fromEntity], conforme o padrão descrito no item 5.2 da
/// proposta arquitetural.
class UserDto {
  /// Identificador do documento no Firestore (UID do Firebase Auth).
  final String id;

  /// Nome completo informado no cadastro.
  final String name;

  /// E-mail utilizado para autenticação.
  final String email;

  /// URL pública do avatar do usuário, quando informada.
  final String? avatarUrl;

  /// Saldo informativo do usuário.
  final double balance;

  /// Data de criação da conta.
  final DateTime createdAt;

  /// Cria um [UserDto].
  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.balance,
    required this.createdAt,
  });

  /// Constrói um [UserDto] a partir de um [DocumentSnapshot] do Firestore.
  factory UserDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserDto(
      id: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      balance: (data['balance'] as num? ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Constrói um [UserDto] a partir de um [Map] genérico, identificado por
  /// [id]. Útil para conversões a partir de dados cacheados.
  factory UserDto.fromMap(String id, Map<String, dynamic> data) {
    return UserDto(
      id: id,
      name: data['name'] as String,
      email: data['email'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      balance: (data['balance'] as num? ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Cria um [UserDto] a partir da entidade de domínio [user].
  factory UserDto.fromEntity(AppUser user) => UserDto(
        id: user.id,
        name: user.name,
        email: user.email,
        avatarUrl: user.avatarUrl,
        balance: user.balance,
        createdAt: user.createdAt,
      );

  /// Serializa o DTO no formato aceito pelo Firestore.
  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'balance': balance,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  /// Converte o DTO em uma entidade de domínio [AppUser], desacoplando o
  /// resto do aplicativo do tipo `Timestamp` do Firestore.
  AppUser toEntity() => AppUser(
        id: id,
        name: name,
        email: email,
        avatarUrl: avatarUrl,
        balance: balance,
        createdAt: createdAt,
      );
}
