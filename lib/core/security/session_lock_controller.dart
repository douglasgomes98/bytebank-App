import 'dart:async';

import 'package:flutter/widgets.dart';

import 'biometric_authenticator.dart';
import 'secure_storage.dart';
import 'secure_storage_keys.dart';

/// Estado do bloqueio de sessão por biometria.
enum SessionLockState {
  /// O bloqueio não está ativo (usuário não habilitou biometria).
  inactive,

  /// O bloqueio está ativo e o conteúdo sensível está visível.
  unlocked,

  /// O bloqueio está ativo e exige autenticação para liberar a UI.
  locked,
}

/// Controla o bloqueio de sessão por biometria ao retorno do app ao
/// foreground.
///
/// O bloqueio é estritamente *opt-in*: nenhuma alteração ocorre na UX
/// enquanto o usuário não ativar a flag persistida em [SecureStorage]
/// sob [SecureStorageKeys.biometricEnabled]. Isso preserva o
/// comportamento original do app.
class SessionLockController extends ChangeNotifier
    with WidgetsBindingObserver {
  final SecureStorage _secureStorage;
  final BiometricAuthenticator _authenticator;

  SessionLockState _state = SessionLockState.inactive;
  bool _attached = false;

  /// Cria o controlador.
  SessionLockController({
    required SecureStorage secureStorage,
    required BiometricAuthenticator authenticator,
  })  : _secureStorage = secureStorage,
        _authenticator = authenticator;

  /// Estado atual do bloqueio.
  SessionLockState get state => _state;

  /// Conveniência para a `AuthGate`: apenas indica se o conteúdo
  /// sensível pode ser exibido.
  bool get isUnlocked =>
      _state == SessionLockState.inactive ||
      _state == SessionLockState.unlocked;

  /// Acopla o controlador ao ciclo de vida do app. Deve ser chamado
  /// uma única vez, na construção da árvore de widgets raiz.
  void attach() {
    if (_attached) return;
    _attached = true;
    WidgetsBinding.instance.addObserver(this);
  }

  /// Desacopla o controlador. Em produção, equivale ao tempo de vida do
  /// app e raramente é invocado.
  void detach() {
    if (!_attached) return;
    _attached = false;
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Recalcula o estado do bloqueio com base na flag persistida e na
  /// existência de uma sessão autenticada.
  ///
  /// Quando [hasAuthenticatedSession] é falso, o bloqueio é
  /// desativado: a tela de login não é considerada conteúdo sensível.
  ///
  /// Quando [freshSignIn] é verdadeiro, o usuário acabou de provar a
  /// identidade no fluxo de login dentro desta mesma execução do app,
  /// portanto o conteúdo pode ser liberado sem nova solicitação. Em
  /// cold start (sessão restaurada do Firebase), [freshSignIn] é
  /// falso e o gate exige biometria antes de revelar dados.
  Future<void> refresh({
    required bool hasAuthenticatedSession,
    required bool freshSignIn,
  }) async {
    if (!hasAuthenticatedSession) {
      if (_state != SessionLockState.inactive) {
        _state = SessionLockState.inactive;
        notifyListeners();
      }
      return;
    }

    final enabled = await _isBiometricEnabled();
    if (!enabled) {
      if (_state != SessionLockState.inactive) {
        _state = SessionLockState.inactive;
        notifyListeners();
      }
      return;
    }

    if (_state == SessionLockState.inactive) {
      _state = freshSignIn
          ? SessionLockState.unlocked
          : SessionLockState.locked;
      notifyListeners();
    }
  }

  /// Solicita a autenticação biométrica e, em sucesso, libera o
  /// conteúdo. Em falha, mantém [SessionLockState.locked].
  Future<bool> unlock({
    String reason = 'Confirme sua identidade para continuar',
  }) async {
    final result = await _authenticator.authenticate(reason: reason);
    if (result == BiometricAuthResult.success) {
      _state = SessionLockState.unlocked;
      notifyListeners();
      return true;
    }
    if (_state != SessionLockState.locked) {
      _state = SessionLockState.locked;
      notifyListeners();
    }
    return false;
  }

  /// Conveniência para ativar/desativar a flag em [SecureStorage].
  ///
  /// Quando habilita, promove o estado interno de [SessionLockState.inactive]
  /// para [SessionLockState.unlocked] de modo que, na próxima ida do app
  /// para background, o [didChangeAppLifecycleState] passe a observar
  /// transições e marque o conteúdo como bloqueado. Sem essa promoção
  /// inicial, o controlador permanece passivo até a próxima
  /// reinicialização.
  Future<void> setBiometricEnabled(bool enabled) async {
    if (enabled) {
      await _secureStorage.write(
        key: SecureStorageKeys.biometricEnabled,
        value: 'true',
      );
      if (_state == SessionLockState.inactive) {
        _state = SessionLockState.unlocked;
      }
    } else {
      await _secureStorage.delete(key: SecureStorageKeys.biometricEnabled);
      _state = SessionLockState.inactive;
    }
    notifyListeners();
  }

  /// Lê a flag e retorna `true` quando a biometria está habilitada.
  Future<bool> isBiometricEnabled() => _isBiometricEnabled();

  Future<bool> _isBiometricEnabled() async {
    final value =
        await _secureStorage.read(key: SecureStorageKeys.biometricEnabled);
    return value == 'true';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_state == SessionLockState.inactive) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive) {
      if (_state != SessionLockState.locked) {
        _state = SessionLockState.locked;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    detach();
    super.dispose();
  }
}
