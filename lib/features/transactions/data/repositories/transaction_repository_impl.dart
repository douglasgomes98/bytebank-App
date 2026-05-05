import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/firebase_storage_data_source.dart';
import '../datasources/firestore_transaction_data_source.dart';
import '../dtos/transaction_dto.dart';

/// Implementação concreta de [TransactionRepository].
///
/// Coordena [FirestoreTransactionDataSource] (persistência) e
/// [FirebaseStorageDataSource] (comprovantes) e traduz exceções em
/// valores [Failure].
class TransactionRepositoryImpl implements TransactionRepository {
  final FirestoreTransactionDataSource _firestoreDataSource;
  final FirebaseStorageDataSource _storageDataSource;
  final Uuid _uuid;

  /// Cria um [TransactionRepositoryImpl].
  TransactionRepositoryImpl({
    required FirestoreTransactionDataSource firestoreDataSource,
    required FirebaseStorageDataSource storageDataSource,
    Uuid? uuid,
  })  : _firestoreDataSource = firestoreDataSource,
        _storageDataSource = storageDataSource,
        _uuid = uuid ?? const Uuid();

  @override
  Stream<List<TransactionEntity>> watchTransactions(String userId) {
    return _firestoreDataSource.watchTransactions(userId).map(
          (list) => list.map((dto) => dto.toEntity()).toList(growable: false),
        );
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction({
    required TransactionEntity transaction,
    File? receiptFile,
  }) async {
    try {
      String? receiptUrl = transaction.receiptUrl;
      if (receiptFile != null) {
        receiptUrl = await _storageDataSource.uploadReceipt(
          userId: transaction.userId,
          file: receiptFile,
        );
      }

      final toPersist = transaction.copyWith(
        id: transaction.id.isEmpty ? _uuid.v4() : transaction.id,
        receiptUrl: receiptUrl,
        createdAt: transaction.createdAt,
      );

      final dto = await _firestoreDataSource
          .create(TransactionDto.fromEntity(toPersist));
      return Right(dto.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction({
    required TransactionEntity transaction,
    File? newReceiptFile,
  }) async {
    try {
      String? receiptUrl = transaction.receiptUrl;
      if (newReceiptFile != null) {
        if (receiptUrl != null) {
          await _storageDataSource.deleteReceipt(receiptUrl);
        }
        receiptUrl = await _storageDataSource.uploadReceipt(
          userId: transaction.userId,
          file: newReceiptFile,
        );
      }

      final updated = transaction.copyWith(receiptUrl: receiptUrl);
      await _firestoreDataSource.update(TransactionDto.fromEntity(updated));
      return Right(updated);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      if (transaction.receiptUrl != null) {
        await _storageDataSource.deleteReceipt(transaction.receiptUrl!);
      }
      await _firestoreDataSource.delete(transaction.id);
      return const Right(unit);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }
}
