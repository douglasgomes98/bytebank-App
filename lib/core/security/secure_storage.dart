/// Contrato de armazenamento seguro consumido pela camada de dados.
///
/// Reservado, conforme o item 9 da proposta arquitetural, para a integração
/// futura com `flutter_secure_storage` (Keychain no iOS, EncryptedShared
/// Preferences no Android). Esta classe define o contrato mínimo que o
/// `SecureCredentialsDataSource` da feature `auth` consumirá quando a
/// integração for habilitada, evitando dependência em tipos concretos da
/// camada de dados.
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
}
