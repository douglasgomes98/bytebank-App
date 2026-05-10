import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Inicializa o Firebase App Check com providers apropriados a cada
/// ambiente.
///
/// Em debug usa o `DebugProvider`, que imprime um token a ser
/// cadastrado manualmente no Console do Firebase. Em release usa Play
/// Integrity (Android) e App Attest com fallback para DeviceCheck (iOS).
class AppCheckBootstrap {
  const AppCheckBootstrap._();

  /// Ativa o App Check para a instância padrão do Firebase. Deve ser
  /// chamado uma única vez, logo após `Firebase.initializeApp`.
  static Future<void> activate() async {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
      appleProvider:
          kReleaseMode ? AppleProvider.appAttestWithDeviceCheckFallback : AppleProvider.debug,
    );
  }
}
