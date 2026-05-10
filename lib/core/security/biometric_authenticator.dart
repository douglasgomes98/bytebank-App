/// Contrato de autenticação biométrica local.
///
/// Interface Dart pura para que o domínio não dependa do pacote
/// `local_auth`.
library;

/// Resultado de uma checagem de disponibilidade biométrica.
enum BiometricAvailability {
  /// Dispositivo possui hardware biométrico cadastrado e disponível.
  available,

  /// Hardware existente, porém o usuário não cadastrou nenhuma biometria.
  notEnrolled,

  /// Dispositivo não possui hardware biométrico ou está bloqueado pelo
  /// sistema (lockout temporário/permanente).
  unavailable,
}

/// Resultado de uma tentativa de autenticação biométrica.
enum BiometricAuthResult {
  /// Usuário autenticou-se com sucesso.
  success,

  /// Usuário cancelou ou a autenticação falhou em tempo de execução.
  failed,

  /// Plataforma indicou que a biometria está indisponível.
  unavailable,
}

/// Abstração que descreve os comandos de autenticação biométrica
/// consumidos pela camada de apresentação.
abstract class BiometricAuthenticator {
  /// Avalia a disponibilidade do hardware biométrico.
  Future<BiometricAvailability> availability();

  /// Solicita autenticação ao usuário, exibindo [reason] como
  /// justificativa visível.
  Future<BiometricAuthResult> authenticate({required String reason});
}
