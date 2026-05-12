import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository _repository;

  const UpdateTransaction(this._repository);

  Future<Either<Failure, Unit>> call({
    required TransactionEntity transaction,
    File? newReceiptFile,
  }) =>
      _repository.updateTransaction(
        transaction: transaction,
        newReceiptFile: newReceiptFile,
      );
}
