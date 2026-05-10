import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/usecases/ensure_fresh_session.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Caso de uso responsável por atualizar uma transação existente.
class UpdateTransaction {
  final TransactionRepository _repository;
  final EnsureFreshSession _ensureFreshSession;

  /// Cria um caso de uso ligado a [_repository] e à validação de
  /// sessão [_ensureFreshSession].
  const UpdateTransaction(this._repository, this._ensureFreshSession);

  /// Atualiza [transaction]. Quando [newReceiptFile] é informado, o
  /// comprovante anterior é substituído pelo novo, replicando a regra
  /// de negócio já existente.
  Future<Either<Failure, TransactionEntity>> call({
    required TransactionEntity transaction,
    File? newReceiptFile,
  }) async {
    final session = await _ensureFreshSession();
    return session.fold(
      Left.new,
      (_) => _repository.updateTransaction(
        transaction: transaction,
        newReceiptFile: newReceiptFile,
      ),
    );
  }
}
