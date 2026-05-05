import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_type.dart';

/// Data Transfer Object correspondente ao documento de transação no
/// Firestore.
///
/// Mantém o conhecimento sobre o esquema remoto isolado da camada de
/// domínio e fornece os métodos `fromMap`/`toMap`, [fromFirestore] e
/// [toEntity]/[fromEntity] descritos no item 5.2 da proposta arquitetural.
class TransactionDto {
  /// Identificador do documento.
  final String id;

  /// Identificador do usuário dono da transação.
  final String userId;

  /// Texto descritivo informado pelo usuário.
  final String description;

  /// Valor da transação em reais.
  final double amount;

  /// Tipo da transação.
  final TransactionType type;

  /// Categoria da transação.
  final TransactionCategory category;

  /// Data informada pelo usuário.
  final DateTime date;

  /// URL do comprovante anexado, quando existir.
  final String? receiptUrl;

  /// Observações livres informadas pelo usuário.
  final String? notes;

  /// Data de criação do registro.
  final DateTime createdAt;

  /// Cria um [TransactionDto].
  const TransactionDto({
    required this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.receiptUrl,
    this.notes,
    required this.createdAt,
  });

  /// Constrói um [TransactionDto] a partir de um [DocumentSnapshot] do
  /// Firestore.
  factory TransactionDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionDto(
      id: doc.id,
      userId: data['userId'] as String,
      description: data['description'] as String,
      amount: (data['amount'] as num).toDouble(),
      type: TransactionTypeExtension.fromString(data['type'] as String),
      category:
          TransactionCategoryExtension.fromString(data['category'] as String),
      date: (data['date'] as Timestamp).toDate(),
      receiptUrl: data['receiptUrl'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Constrói um [TransactionDto] a partir de um [Map] genérico,
  /// identificado por [id]. Útil para conversões a partir de cache.
  factory TransactionDto.fromMap(String id, Map<String, dynamic> data) {
    return TransactionDto(
      id: id,
      userId: data['userId'] as String,
      description: data['description'] as String,
      amount: (data['amount'] as num).toDouble(),
      type: TransactionTypeExtension.fromString(data['type'] as String),
      category:
          TransactionCategoryExtension.fromString(data['category'] as String),
      date: (data['date'] as Timestamp).toDate(),
      receiptUrl: data['receiptUrl'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Cria um [TransactionDto] a partir da entidade de domínio
  /// [transaction].
  factory TransactionDto.fromEntity(TransactionEntity transaction) {
    return TransactionDto(
      id: transaction.id,
      userId: transaction.userId,
      description: transaction.description,
      amount: transaction.amount,
      type: transaction.type,
      category: transaction.category,
      date: transaction.date,
      receiptUrl: transaction.receiptUrl,
      notes: transaction.notes,
      createdAt: transaction.createdAt,
    );
  }

  /// Serializa o DTO no formato aceito pelo Firestore.
  Map<String, dynamic> toMap() => {
        'userId': userId,
        'description': description,
        'amount': amount,
        'type': type.name,
        'category': category.name,
        'date': Timestamp.fromDate(date),
        'receiptUrl': receiptUrl,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  /// Converte o DTO em uma entidade de domínio [TransactionEntity].
  TransactionEntity toEntity() => TransactionEntity(
        id: id,
        userId: userId,
        description: description,
        amount: amount,
        type: type,
        category: category,
        date: date,
        receiptUrl: receiptUrl,
        notes: notes,
        createdAt: createdAt,
      );
}
