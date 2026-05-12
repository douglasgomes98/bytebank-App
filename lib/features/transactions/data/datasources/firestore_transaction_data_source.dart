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

  Stream<List<TransactionDto>> watchTransactions(
    String userId, {
    int limit = 20,
  }) {
    return _db
        .collection(AppConstants.transactionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(TransactionDto.fromFirestore).toList());
  }

  Future<List<TransactionDto>> fetchPage(
    String userId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      var query = _db
          .collection(AppConstants.transactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map(TransactionDto.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao buscar transações', code: e.code);
    }
  }

  Future<DocumentSnapshot?> getDocumentSnapshot(String transactionId) async {
    try {
      final doc = await _db
          .collection(AppConstants.transactionsCollection)
          .doc(transactionId)
          .get();
      return doc.exists ? doc : null;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro ao buscar documento', code: e.code);
    }
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
