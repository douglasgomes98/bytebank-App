import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/app_user.dart';

/// Contrato do repositório de autenticação.
///
/// Define operações de negócio em termos de entidades de domínio. As
/// implementações ficam na camada de dados e traduzem as exceções de
/// infraestrutura (Firebase) em valores [Failure] tipados, conforme o
/// item 5 da proposta arquitetural.
abstract class AuthRepository {
  /// Stream que emite o usuário autenticado atual ou `null` quando o
  /// usuário está deslogado. Usado pela `AuthGate` para reagir a logins
  /// realizados em outras abas/instâncias.
  Stream<AppUser?> watchAuthState();

  /// Retorna o usuário atualmente autenticado ou `null` quando não há
  /// sessão ativa.
  Future<Either<Failure, AppUser?>> getCurrentUser();

  /// Realiza o login de um usuário existente com [email] e [password].
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  });

  /// Cria uma nova conta para o usuário.
  ///
  /// Após a criação, a sessão é encerrada para que o usuário seja
  /// obrigado a entrar manualmente, preservando o fluxo já existente.
  Future<Either<Failure, AppUser>> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Encerra a sessão atual.
  Future<Either<Failure, Unit>> signOut();

  /// Envia um e-mail de redefinição de senha para [email].
  Future<Either<Failure, Unit>> resetPassword(String email);

  /// Força a revalidação do token de sessão atual antes de uma operação
  /// sensível, garantindo que a credencial usada nas requisições
  /// subsequentes não esteja expirada ou revogada.
  Future<Either<Failure, Unit>> ensureFreshSession();
}
