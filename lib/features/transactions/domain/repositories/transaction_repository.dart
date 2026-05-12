import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/constants.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Stream<Either<Failure, List<TransactionEntity>>> watchTransactions(
    String userId, {
    int limit = AppConstants.transactionsPageSize,
  });

  Future<Either<Failure, List<TransactionEntity>>> fetchNextPage({
    required String userId,
    required String? lastTransactionId,
    int limit = AppConstants.transactionsPageSize,
  });

  Future<Either<Failure, Unit>> createTransaction({
    required TransactionEntity transaction,
    File? receiptFile,
  });

  Future<Either<Failure, Unit>> updateTransaction({
    required TransactionEntity transaction,
    File? newReceiptFile,
  });

  Future<Either<Failure, Unit>> deleteTransaction({
    required String transactionId,
  });
}
