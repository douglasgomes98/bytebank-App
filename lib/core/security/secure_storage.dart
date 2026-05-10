/// Contrato de armazenamento seguro consumido pela camada de dados.
///
/// Persiste valores sensíveis exclusivamente em enclaves do sistema
/// operacional (Keychain no iOS, Keystore/EncryptedSharedPreferences no
/// Android). O contrato é Dart puro para que o domínio não dependa do
/// pacote `flutter_secure_storage`.
library;

/// Abstração para leitura, escrita e remoção de valores sensíveis em
/// armazenamento seguro do sistema operacional.
abstract class SecureStorage {
  /// Persiste [value] na chave [key].
  Future<void> write({required String key, required String value});

  /// Lê o valor associado a [key] ou `null` quando inexistente.
  Future<String?> read({required String key});

  /// Remove o valor associado a [key].
  Future<void> delete({required String key});

  /// Remove todos os valores deste storage. Usado, por exemplo, no
  /// logout para invalidar credenciais residuais.
  Future<void> deleteAll();

  /// `true` quando há valor associado a [key].
  Future<bool> containsKey({required String key});
}
