import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Caso de uso responsável por excluir uma transação e o respectivo
/// comprovante, quando existir.
class DeleteTransaction {
  final TransactionRepository _repository;

  /// Cria um caso de uso ligado a [_repository].
  const DeleteTransaction(this._repository);

  /// Remove [transaction]. A implementação do repositório também remove
  /// o comprovante associado no Storage, quando presente.
  Future<Either<Failure, Unit>> call(TransactionEntity transaction) =>
      _repository.deleteTransaction(transaction);
}
