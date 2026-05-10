import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/security/biometric_authenticator.dart';
import '../../../../core/utils/secure_logger.dart';

/// Implementação de [BiometricAuthenticator] sobre o pacote `local_auth`.
///
/// Encapsula as exceções de plataforma e classifica a disponibilidade
/// em uma das três opções de [BiometricAvailability] consumidas pela
/// camada de apresentação, evitando que `PlatformException` ou enums do
/// pacote vazem para fora da camada de dados.
class LocalAuthBiometricAuthenticator implements BiometricAuthenticator {
  final LocalAuthentication _delegate;

  /// Cria o autenticador. A instância pode ser injetada para testes.
  LocalAuthBiometricAuthenticator({LocalAuthentication? delegate})
      : _delegate = delegate ?? LocalAuthentication();

  @override
  Future<BiometricAvailability> availability() async {
    try {
      final supported = await _delegate.isDeviceSupported();
      final canCheck = await _delegate.canCheckBiometrics;
      final available = await _delegate.getAvailableBiometrics();
      SecureLogger.info(
        'biometric availability: isDeviceSupported=$supported, '
        'canCheckBiometrics=$canCheck, '
        'availableBiometrics=$available',
      );
      if (!supported) return BiometricAvailability.unavailable;
      if (!canCheck) return BiometricAvailability.unavailable;
      if (available.isEmpty) return BiometricAvailability.notEnrolled;
      return BiometricAvailability.available;
    } on PlatformException catch (e) {
      SecureLogger.warning('biometric availability platform error: ${e.code}');
      return BiometricAvailability.unavailable;
    }
  }

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async {
    try {
      final ok = await _delegate.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return ok ? BiometricAuthResult.success : BiometricAuthResult.failed;
    } on PlatformException {
      return BiometricAuthResult.unavailable;
    }
  }
}
