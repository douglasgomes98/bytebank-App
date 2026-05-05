import 'package:cloud_firestore/cloud_firestore.dart';
import 'category.dart';

enum TransactionType { income, expense, transfer }

extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Receita';
      case TransactionType.expense:
        return 'Despesa';
      case TransactionType.transfer:
        return 'Transferência';
    }
  }

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}

class Transaction {
  final String id;
  final String userId;
  final String description;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String? receiptUrl;
  final String? notes;
  final DateTime createdAt;

  const Transaction({
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

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      userId: data['userId'] as String,
      description: data['description'] as String,
      amount: (data['amount'] as num).toDouble(),
      type: TransactionTypeExtension.fromString(data['type'] as String),
      category: TransactionCategoryExtension.fromString(
        data['category'] as String,
      ),
      date: (data['date'] as Timestamp).toDate(),
      receiptUrl: data['receiptUrl'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
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
  }

  Transaction copyWith({
    String? id,
    String? userId,
    String? description,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? receiptUrl,
    String? notes,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
