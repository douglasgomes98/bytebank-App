import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Caso de uso responsável por criar uma nova transação.
///
/// Quando [receiptFile] é informado, o repositório encarrega-se de
/// publicar o arquivo no Storage e persistir a URL retornada na
/// transação criada.
class CreateTransaction {
  final TransactionRepository _repository;

  /// Cria um caso de uso ligado a [_repository].
  const CreateTransaction(this._repository);

  /// Persiste [transaction] e, opcionalmente, anexa [receiptFile] como
  /// comprovante.
  Future<Either<Failure, TransactionEntity>> call({
    required TransactionEntity transaction,
    File? receiptFile,
  }) =>
      _repository.createTransaction(
        transaction: transaction,
        receiptFile: receiptFile,
      );
}
