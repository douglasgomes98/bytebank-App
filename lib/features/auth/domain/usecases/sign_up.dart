import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso responsável por criar uma nova conta na aplicação.
///
/// Mantém a regra de negócio existente: após a criação da conta, a sessão
/// é imediatamente encerrada e o usuário é redirecionado para a tela de
/// login para autenticar-se manualmente.
class SignUp {
  final AuthRepository _repository;

  /// Cria um caso de uso ligado a [_repository].
  const SignUp(this._repository);

  /// Executa o cadastro com [name], [email] e [password].
  Future<Either<Failure, AppUser>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.signUp(name: name, email: email, password: password);
  }
}
