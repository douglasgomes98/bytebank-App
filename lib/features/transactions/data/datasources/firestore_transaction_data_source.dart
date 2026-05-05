import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../dtos/transaction_dto.dart';

/// Fonte de dados que encapsula as operações de transação no Firestore.
///
/// Trabalha exclusivamente com [TransactionDto] para que o repositório
/// possa fazer a conversão final em [TransactionEntity]. Lança
/// [ServerException] em qualquer falha.
class FirestoreTransactionDataSource {
  final FirebaseFirestore _db;

  /// Cria um [FirestoreTransactionDataSource]. A instância do Firestore
  /// pode ser injetada para facilitar testes.
  FirestoreTransactionDataSource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Stream que reflete em tempo real a coleção de transações do
  /// usuário [userId]. A ordenação por data decrescente é feita em Dart
  /// para evitar a necessidade de um índice composto no Firestore,
  /// preservando o comportamento da implementação anterior.
  Stream<List<TransactionDto>> watchTransactions(String userId) {
    return _db
        .collection(AppConstants.transactionsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map(TransactionDto.fromFirestore).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  /// Persiste [dto] como um novo documento e retorna o DTO atualizado
  /// com o `id` gerado pelo Firestore.
  Future<TransactionDto> create(TransactionDto dto) async {
    try {
      final ref = await _db
          .collection(AppConstants.transactionsCollection)
          .add(dto.toMap());
      return TransactionDto(
        id: ref.id,
        userId: dto.userId,
        description: dto.description,
        amount: dto.amount,
        type: dto.type,
        category: dto.category,
        date: dto.date,
        receiptUrl: dto.receiptUrl,
        notes: dto.notes,
        createdAt: dto.createdAt,
      );
    } on FirebaseException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao criar transação',
        code: e.code,
      );
    }
  }

  /// Atualiza o documento correspondente a [dto] com os dados informados.
  Future<void> update(TransactionDto dto) async {
    try {
      await _db
          .collection(AppConstants.transactionsCollection)
          .doc(dto.id)
          .update(dto.toMap());
    } on FirebaseException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao atualizar transação',
        code: e.code,
      );
    }
  }

  /// Remove o documento de [transactionId].
  Future<void> delete(String transactionId) async {
    try {
      await _db
          .collection(AppConstants.transactionsCollection)
          .doc(transactionId)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        e.message ?? 'Erro ao excluir transação',
        code: e.code,
      );
    }
  }
}
