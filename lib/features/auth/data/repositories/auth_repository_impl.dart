import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_data_source.dart';

/// Implementação concreta de [AuthRepository].
///
/// Orquestra as chamadas ao [FirebaseAuthDataSource] e converte cada
/// [AppException] capturada em um [Failure] tipado, conforme descrito
/// no item 5.2 da proposta arquitetural.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  /// Cria um [AuthRepositoryImpl] ligado a [_dataSource].
  const AuthRepositoryImpl(this._dataSource);

  @override
  Stream<AppUser?> watchAuthState() async* {
    await for (final firebaseUser in _dataSource.authStateChanges()) {
      if (firebaseUser == null) {
        yield null;
      } else {
        try {
          final dto = await _dataSource.fetchUser(firebaseUser.uid);
          yield dto?.toEntity();
        } on AppException {
          yield null;
        }
      }
    }
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async {
    final id = _dataSource.currentUserId;
    if (id == null) return const Right(null);
    try {
      final dto = await _dataSource.fetchUser(id);
      return Right(dto?.toEntity());
    } on AuthException catch (e) {
      return Left(_mapAuthFailure(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _dataSource.signIn(email: email, password: password);
      return Right(dto.toEntity());
    } on AuthException catch (e) {
      return Left(_mapAuthFailure(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _dataSource.signUp(
        name: name,
        email: email,
        password: password,
      );
      return Right(dto.toEntity());
    } on AuthException catch (e) {
      return Left(_mapAuthFailure(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(_mapAuthFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(String email) async {
    try {
      await _dataSource.resetPassword(email);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(_mapAuthFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> ensureFreshSession() async {
    try {
      await _dataSource.refreshIdToken();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(_mapAuthFailure(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  /// Traduz um [AuthException] para uma [AuthFailure] com mensagem em
  /// português, preservando a mesma tabela de mapeamento usada
  /// anteriormente em `AuthProvider._mapFirebaseError`.
  AuthFailure _mapAuthFailure(AuthException e) {
    return AuthFailure(_localizeAuthCode(e.code), code: e.code);
  }

  /// Traduz o código retornado pelo Firebase Auth em uma mensagem
  /// localizada em português.
  String _localizeAuthCode(String? code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'E-mail já está em uso';
      case 'invalid-email':
        return 'E-mail inválido';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 'network-request-failed':
        return 'Sem conexão com a internet';
      default:
        return 'Erro de autenticação. Tente novamente';
    }
  }
}
