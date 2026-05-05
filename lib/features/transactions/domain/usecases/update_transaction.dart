import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Caso de uso responsável por atualizar uma transação existente.
class UpdateTransaction {
  final TransactionRepository _repository;

  /// Cria um caso de uso ligado a [_repository].
  const UpdateTransaction(this._repository);

  /// Atualiza [transaction]. Quando [newReceiptFile] é informado, o
  /// comprovante anterior é substituído pelo novo, replicando a regra
  /// de negócio já existente.
  Future<Either<Failure, TransactionEntity>> call({
    required TransactionEntity transaction,
    File? newReceiptFile,
  }) =>
      _repository.updateTransaction(
        transaction: transaction,
        newReceiptFile: newReceiptFile,
      );
}
