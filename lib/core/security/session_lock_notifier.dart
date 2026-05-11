import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/core/providers/core_providers.dart';
import 'package:bytebank_app/core/security/biometric_authenticator.dart';

part 'session_lock_notifier.g.dart';

@Riverpod(keepAlive: true)
class SessionLockNotifier extends _$SessionLockNotifier {
  @override
  bool build() => false;

  Future<void> lock() async => state = true;

  Future<void> unlock() async {
    final biometric = ref.read(biometricAuthenticatorProvider);
    final result = await biometric.authenticate(
      reason: 'Confirme sua identidade para continuar',
    );
    if (result == BiometricAuthResult.success) state = false;
  }
}
