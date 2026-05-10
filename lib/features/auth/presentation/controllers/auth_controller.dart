import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/security/secure_storage.dart';
import '../../../../core/security/secure_storage_keys.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/watch_auth_state.dart';

/// Estados possíveis do fluxo de autenticação observado pela `AuthGate`.
enum AuthStatus {
  /// Estado inicial, antes de qualquer evento de autenticação ser
  /// emitido.
  initial,

  /// Operação em andamento (login, cadastro, recuperação de sessão).
  loading,

  /// Sessão autenticada e [AppUser] disponível.
  authenticated,

  /// Sem sessão ativa.
  unauthenticated,

  /// Última operação falhou. A `errorMessage` está populada.
  error,
}

/// Controller (camada de apresentação) que orquestra os casos de uso de
/// autenticação e expõe um estado observável para a UI.
///
/// O [AuthController] não conhece Firebase: invoca apenas os casos de uso
/// recebidos via construtor, mantendo a Regra de Dependência da Clean
/// Architecture.
class AuthController extends ChangeNotifier {
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final ResetPassword _resetPassword;
  final GetCurrentUser _getCurrentUser;
  final WatchAuthState _watchAuthState;
  final SecureStorage _secureStorage;

  StreamSubscription<AppUser?>? _authSubscription;

  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _errorMessage;

  /// Cria um [AuthController] ligado aos casos de uso.
  ///
  /// Inicia imediatamente a escuta do stream de autenticação para
  /// reagir a mudanças de sessão (login, logout) emitidas em qualquer
  /// parte da aplicação.
  AuthController({
    required SignIn signIn,
    required SignUp signUp,
    required SignOut signOut,
    required ResetPassword resetPassword,
    required GetCurrentUser getCurrentUser,
    required WatchAuthState watchAuthState,
    required SecureStorage secureStorage,
  })  : _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _resetPassword = resetPassword,
        _getCurrentUser = getCurrentUser,
        _watchAuthState = watchAuthState,
        _secureStorage = secureStorage {
    _authSubscription = _watchAuthState().listen(_onAuthStateChanged);
  }

  /// Estado atual do fluxo de autenticação.
  AuthStatus get status => _status;

  /// Usuário atualmente autenticado, ou `null` quando não há sessão.
  AppUser? get user => _user;

  /// Mensagem de erro localizada, presente apenas quando
  /// [status] == [AuthStatus.error].
  String? get errorMessage => _errorMessage;

  /// `true` quando há uma sessão autenticada.
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Reage a uma emissão do stream de autenticação.
  ///
  /// Quando [appUser] é `null`, o estado torna-se
  /// [AuthStatus.unauthenticated]. Quando há um [AppUser], o estado é
  /// promovido para [AuthStatus.authenticated]. Caso o stream emita um
  /// usuário sem documento associado, executa-se uma busca explícita
  /// via [GetCurrentUser] como segurança adicional.
  Future<void> _onAuthStateChanged(AppUser? appUser) async {
    if (appUser == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _user = appUser;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  /// Realiza o login com [email] e [password]. Retorna `true` em caso
  /// de sucesso, preservando o contrato consumido pela tela de login.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _signIn(email: email, password: password);
    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (appUser) {
        _user = appUser;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      },
    );
  }

  /// Realiza o cadastro e, em caso de sucesso, retorna `true`.
  ///
  /// Após o cadastro o usuário é deslogado pela camada de dados,
  /// portanto o estado final é [AuthStatus.unauthenticated], replicando
  /// o fluxo "criar conta + voltar para login" original.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result =
        await _signUp(name: name, email: email, password: password);
    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return true;
      },
    );
  }

  /// Encerra a sessão atual e retorna ao estado
  /// [AuthStatus.unauthenticated]. Também invalida credenciais residuais
  /// no armazenamento seguro, com exceção da chave criptográfica
  /// mestra (que precisa sobreviver ao logout para preservar caches
  /// cifrados de outros usuários no mesmo dispositivo).
  Future<void> signOut() async {
    final result = await _signOut();
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (_) async {
        await _wipeUserScopedSecureStorage();
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      },
    );
  }

  Future<void> _wipeUserScopedSecureStorage() async {
    await _secureStorage.delete(key: SecureStorageKeys.biometricEnabled);
    await _secureStorage.delete(
      key: SecureStorageKeys.lastSignedInEmailCiphertext,
    );
  }

  /// Solicita o envio do e-mail de redefinição de senha. Retorna `true`
  /// em caso de sucesso.
  Future<bool> resetPassword(String email) async {
    final result = await _resetPassword(email);
    return result.isRight();
  }

  /// Atualiza o [AppUser] em memória, útil para refletir mudanças
  /// realizadas em outras telas (perfil, por exemplo).
  void updateUser(AppUser user) {
    _user = user;
    notifyListeners();
  }

  /// Limpa qualquer mensagem de erro pendente.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Recupera o usuário atual via caso de uso (utilizado pela UI quando
  /// o stream ainda não emitiu).
  Future<void> refreshCurrentUser() async {
    final result = await _getCurrentUser();
    result.fold(
      (_) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      },
      (appUser) {
        _user = appUser;
        _status = appUser == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
