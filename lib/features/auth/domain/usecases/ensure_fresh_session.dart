import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso que confirma a frescura do token de sessão antes de
/// operações sensíveis (criação, atualização e exclusão de
/// transações).
///
/// Não altera o fluxo de negócio: apenas força o backend a revalidar a
/// sessão atual; em caso de falha (token revogado, conta desabilitada,
/// rede indisponível), retorna uma [Failure] que a camada de
/// apresentação pode tratar abortando a operação.
class EnsureFreshSession {
  final AuthRepository _repository;

  /// Cria um [EnsureFreshSession] ligado a [_repository].
  const EnsureFreshSession(this._repository);

  /// Executa a verificação. Retorna [Right(unit)] quando a sessão é
  /// válida e refrescável.
  Future<Either<Failure, Unit>> call() => _repository.ensureFreshSession();
}
