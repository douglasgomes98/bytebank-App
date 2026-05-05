import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso responsável por recuperar o usuário atualmente autenticado.
class GetCurrentUser {
  final AuthRepository _repository;

  /// Cria um caso de uso ligado a [_repository].
  const GetCurrentUser(this._repository);

  /// Retorna o [AppUser] da sessão ativa ou `null` quando não há sessão.
  Future<Either<Failure, AppUser?>> call() => _repository.getCurrentUser();
}
