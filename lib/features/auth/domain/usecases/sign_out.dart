import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso responsável por encerrar a sessão do usuário corrente.
class SignOut {
  final AuthRepository _repository;

  /// Cria um caso de uso ligado a [_repository].
  const SignOut(this._repository);

  /// Executa o logout. Retorna [Unit] em caso de sucesso ou um [Failure]
  /// caso a operação falhe.
  Future<Either<Failure, Unit>> call() => _repository.signOut();
}
