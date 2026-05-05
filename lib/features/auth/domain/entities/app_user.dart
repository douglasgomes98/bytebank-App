/// Entidade de domínio que representa o usuário autenticado da aplicação.
///
/// É uma classe Dart pura, imutável e sem dependências de
/// `package:flutter`, `package:firebase_*` ou `package:cloud_firestore`,
/// honrando a Regra de Dependência da Clean Architecture (camada de
/// domínio não conhece infraestrutura).
class AppUser {
  /// Identificador único do usuário (UID do Firebase Authentication).
  final String id;

  /// Nome completo informado no cadastro.
  final String name;

  /// E-mail utilizado para autenticação.
  final String email;

  /// URL pública do avatar do usuário, quando existente.
  final String? avatarUrl;

  /// Saldo informativo do usuário (regra de negócio existente preservada).
  final double balance;

  /// Data em que a conta foi criada.
  final DateTime createdAt;

  /// Cria uma instância imutável de [AppUser].
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.balance,
    required this.createdAt,
  });

  /// Retorna uma cópia desta entidade substituindo apenas os campos
  /// informados, preservando os demais.
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
