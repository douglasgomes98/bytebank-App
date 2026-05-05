import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso que expõe um [Stream] reativo do estado de autenticação.
///
/// O controller observa este stream para refletir, em tempo real, mudanças
/// de sessão (login, logout) realizadas por qualquer parte da aplicação.
class WatchAuthState {
  final AuthRepository _repository;

  /// Cria um caso de uso ligado a [_repository].
  const WatchAuthState(this._repository);

  /// Retorna a stream do usuário autenticado (`null` quando deslogado).
  Stream<AppUser?> call() => _repository.watchAuthState();
}
