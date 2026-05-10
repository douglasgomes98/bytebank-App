import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/usecases/ensure_fresh_session.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Caso de uso responsável por criar uma nova transação.
///
/// Quando [receiptFile] é informado, o repositório encarrega-se de
/// publicar o arquivo no Storage e persistir a URL retornada na
/// transação criada. Antes da gravação, força um refresh do token de
/// sessão para que o Firestore receba uma credencial recém-emitida.
class CreateTransaction {
  final TransactionRepository _repository;
  final EnsureFreshSession _ensureFreshSession;

  /// Cria um caso de uso ligado a [_repository] e à validação de
  /// sessão [_ensureFreshSession].
  const CreateTransaction(this._repository, this._ensureFreshSession);

  /// Persiste [transaction] e, opcionalmente, anexa [receiptFile] como
  /// comprovante.
  Future<Either<Failure, TransactionEntity>> call({
    required TransactionEntity transaction,
    File? receiptFile,
  }) async {
    final session = await _ensureFreshSession();
    return session.fold(
      Left.new,
      (_) => _repository.createTransaction(
        transaction: transaction,
        receiptFile: receiptFile,
      ),
    );
  }
}
