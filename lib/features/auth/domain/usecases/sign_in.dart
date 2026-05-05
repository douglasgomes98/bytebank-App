import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso responsável por autenticar um usuário existente.
///
/// Encapsula a intenção "entrar com e-mail e senha" exposta pela tela de
/// login. Possui o método único [call], conforme o padrão de casos de uso
/// descrito no capítulo 20 de *Clean Architecture* (R. C. Martin).
class SignIn {
  final AuthRepository _repository;

  /// Cria um caso de uso ligado a [_repository].
  const SignIn(this._repository);

  /// Executa o login utilizando [email] e [password].
  ///
  /// Retorna o [AppUser] no caso de sucesso ou um [Failure] descrevendo o
  /// motivo da falha no caso contrário.
  Future<Either<Failure, AppUser>> call({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}
