import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction_entity.dart';

/// Contrato do repositório de transações.
///
/// Define as operações de negócio em termos de [TransactionEntity]. As
/// implementações ficam na camada de dados e traduzem exceções de
/// infraestrutura (Firestore, Storage) em valores [Failure].
abstract class TransactionRepository {
  /// Stream que emite a lista de transações do usuário [userId] em tempo
  /// real. Substitui a leitura única por `Future<List<...>>` por um
  /// fluxo reativo, preservando o comportamento já implementado pelo
  /// `FirestoreService.watchTransactions`.
  Stream<List<TransactionEntity>> watchTransactions(String userId);

  /// Cria uma nova [TransactionEntity], opcionalmente enviando o
  /// arquivo [receiptFile] como comprovante.
  Future<Either<Failure, TransactionEntity>> createTransaction({
    required TransactionEntity transaction,
    File? receiptFile,
  });

  /// Atualiza uma [TransactionEntity] existente. Quando [newReceiptFile]
  /// é informado, o comprovante anterior (se houver) é removido e o novo
  /// é enviado.
  Future<Either<Failure, TransactionEntity>> updateTransaction({
    required TransactionEntity transaction,
    File? newReceiptFile,
  });

  /// Remove a transação informada e o respectivo comprovante, se houver.
  Future<Either<Failure, Unit>> deleteTransaction(
    TransactionEntity transaction,
  );
}
