/// Contrato de criptografia simétrica em repouso (AES-GCM).
///
/// Usa algoritmos auditados (AES-GCM, NIST SP 800-38D), chave gerenciada
/// pelo enclave do sistema operacional via `SecureStorage`, nonce
/// aleatório por operação e nenhuma implementação caseira.
///
/// As entradas são tratadas como `String` UTF-8; o ciphertext devolvido
/// inclui o nonce (prefixo de 12 bytes) e o tag de autenticação,
/// codificado em Base64 para trânsito/armazenamento seguro.
library;

/// Serviço de criptografia simétrica em repouso.
abstract class CryptoService {
  /// Cifra [plaintext] e retorna a representação Base64 do ciphertext.
  Future<String> encrypt(String plaintext);

  /// Decifra um ciphertext em Base64 produzido por [encrypt].
  ///
  /// Lança [CryptoException] caso o tag de autenticação não confira (MAC
  /// inválido) ou o payload esteja corrompido.
  Future<String> decrypt(String ciphertextBase64);
}

/// Exceção lançada por implementações de [CryptoService] quando a
/// operação criptográfica falha (MAC inválido, payload corrompido,
/// chave indisponível).
class CryptoException implements Exception {
  /// Cria uma [CryptoException] com a [message] descritiva.
  const CryptoException(this.message);

  /// Descrição legível da falha.
  final String message;

  @override
  String toString() => 'CryptoException: $message';
}
