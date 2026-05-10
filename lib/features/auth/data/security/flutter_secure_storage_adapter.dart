import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/security/secure_storage.dart';

/// Implementação de [SecureStorage] sobre `flutter_secure_storage`.
///
/// Em Android utiliza `EncryptedSharedPreferences` com chave gerenciada
/// pelo Android Keystore. Em iOS utiliza Keychain Services com a
/// política de acessibilidade `first_unlock_this_device`, exigindo que
/// o dispositivo tenha sido desbloqueado pelo menos uma vez desde a
/// última inicialização — combinando segurança e disponibilidade para
/// background tasks legítimos.
class FlutterSecureStorageAdapter implements SecureStorage {
  final FlutterSecureStorage _delegate;

  /// Cria o adaptador. A instância de [FlutterSecureStorage] pode ser
  /// injetada para fins de teste.
  FlutterSecureStorageAdapter({FlutterSecureStorage? delegate})
      : _delegate = delegate ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  @override
  Future<void> write({required String key, required String value}) {
    return _delegate.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) {
    return _delegate.read(key: key);
  }

  @override
  Future<void> delete({required String key}) {
    return _delegate.delete(key: key);
  }

  @override
  Future<void> deleteAll() => _delegate.deleteAll();

  @override
  Future<bool> containsKey({required String key}) {
    return _delegate.containsKey(key: key);
  }
}
