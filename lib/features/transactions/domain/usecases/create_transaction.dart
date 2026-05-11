import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class CreateTransaction {
  final TransactionRepository _repository;

  const CreateTransaction(this._repository);

  Future<Either<Failure, Unit>> call({
    required TransactionEntity transaction,
    File? receiptFile,
  }) =>
      _repository.createTransaction(
        transaction: transaction,
        receiptFile: receiptFile,
      );
}
