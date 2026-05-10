import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/usecases/ensure_fresh_session.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Caso de uso responsável por excluir uma transação e o respectivo
/// comprovante, quando existir.
class DeleteTransaction {
  final TransactionRepository _repository;
  final EnsureFreshSession _ensureFreshSession;

  /// Cria um caso de uso ligado a [_repository] e à validação de
  /// sessão [_ensureFreshSession].
  const DeleteTransaction(this._repository, this._ensureFreshSession);

  /// Remove [transaction]. A implementação do repositório também remove
  /// o comprovante associado no Storage, quando presente.
  Future<Either<Failure, Unit>> call(TransactionEntity transaction) async {
    final session = await _ensureFreshSession();
    return session.fold(
      Left.new,
      (_) => _repository.deleteTransaction(transaction),
    );
  }
}
