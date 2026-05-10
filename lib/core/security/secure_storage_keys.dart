/// Chaves estáveis usadas pelo armazenamento seguro.
///
/// Centralizar as chaves em uma única classe evita duplicação (princípio
/// DRY) e impede colisões acidentais entre features. Nenhum dado
/// sensível é armazenado fora deste catálogo.
class SecureStorageKeys {
  SecureStorageKeys._();

  /// Indica se o usuário habilitou a exigência de biometria para
  /// reabertura do app.
  static const String biometricEnabled = 'security.biometric_enabled';

  /// Último e-mail utilizado em login bem-sucedido (cifrado em repouso).
  static const String lastSignedInEmailCiphertext =
      'security.last_email_ciphertext';

  /// Chave AES-256 utilizada pelo `CryptoService` para cifrar caches
  /// locais sensíveis. Persistida exclusivamente no enclave do sistema
  /// operacional via `SecureStorage`.
  static const String cryptoMasterKey = 'security.crypto_master_key';
}
