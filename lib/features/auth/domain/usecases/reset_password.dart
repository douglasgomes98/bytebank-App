import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso responsável por enviar um e-mail de redefinição de senha.
class ResetPassword {
  final AuthRepository _repository;

  /// Cria um caso de uso ligado a [_repository].
  const ResetPassword(this._repository);

  /// Dispara o envio do e-mail de redefinição para [email].
  Future<Either<Failure, Unit>> call(String email) =>
      _repository.resetPassword(email);
}
