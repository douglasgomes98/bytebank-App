import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../../../core/security/crypto_service.dart';
import '../../../../core/security/secure_storage.dart';
import '../../../../core/security/secure_storage_keys.dart';

/// Implementação de [CryptoService] que utiliza AES-GCM 256.
///
/// A chave mestra é gerada na primeira execução com um gerador
/// aleatório criptograficamente seguro e persistida exclusivamente em
/// [SecureStorage]. Cada operação utiliza um nonce de 12 bytes
/// independente, prefixado ao ciphertext antes da codificação Base64.
class AesGcmCryptoService implements CryptoService {
  static const int _nonceLength = 12;
  static const int _keyLengthBytes = 32;

  final SecureStorage _secureStorage;
  final AesGcm _algorithm;

  Future<SecretKey>? _keyFuture;

  /// Cria o serviço. O algoritmo concreto pode ser injetado para
  /// testes; em produção usa [AesGcm.with256bits].
  AesGcmCryptoService({
    required SecureStorage secureStorage,
    AesGcm? algorithm,
  })  : _secureStorage = secureStorage,
        _algorithm = algorithm ?? AesGcm.with256bits();

  @override
  Future<String> encrypt(String plaintext) async {
    try {
      final key = await _resolveKey();
      final nonce = _algorithm.newNonce();
      final secretBox = await _algorithm.encrypt(
        utf8.encode(plaintext),
        secretKey: key,
        nonce: nonce,
      );
      final payload = Uint8List(
        nonce.length + secretBox.cipherText.length + secretBox.mac.bytes.length,
      )
        ..setRange(0, nonce.length, nonce)
        ..setRange(
          nonce.length,
          nonce.length + secretBox.cipherText.length,
          secretBox.cipherText,
        )
        ..setRange(
          nonce.length + secretBox.cipherText.length,
          nonce.length +
              secretBox.cipherText.length +
              secretBox.mac.bytes.length,
          secretBox.mac.bytes,
        );
      return base64Encode(payload);
    } catch (e) {
      throw CryptoException('Falha ao cifrar payload: $e');
    }
  }

  @override
  Future<String> decrypt(String ciphertextBase64) async {
    try {
      final bytes = base64Decode(ciphertextBase64);
      if (bytes.length <= _nonceLength + 16) {
        throw const CryptoException('Ciphertext malformado');
      }
      final nonce = bytes.sublist(0, _nonceLength);
      final macStart = bytes.length - 16;
      final cipherText = bytes.sublist(_nonceLength, macStart);
      final macBytes = bytes.sublist(macStart);
      final secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: Mac(macBytes),
      );
      final key = await _resolveKey();
      final clear = await _algorithm.decrypt(secretBox, secretKey: key);
      return utf8.decode(clear);
    } on CryptoException {
      rethrow;
    } on SecretBoxAuthenticationError {
      throw const CryptoException('MAC inválido — payload adulterado');
    } catch (e) {
      throw CryptoException('Falha ao decifrar payload: $e');
    }
  }

  Future<SecretKey> _resolveKey() {
    return _keyFuture ??= _loadOrCreateKey();
  }

  Future<SecretKey> _loadOrCreateKey() async {
    final existing =
        await _secureStorage.read(key: SecureStorageKeys.cryptoMasterKey);
    if (existing != null) {
      return SecretKey(base64Decode(existing));
    }
    final key = await _algorithm.newSecretKey();
    final bytes = await key.extractBytes();
    if (bytes.length != _keyLengthBytes) {
      throw const CryptoException('Falha ao gerar chave AES-256');
    }
    await _secureStorage.write(
      key: SecureStorageKeys.cryptoMasterKey,
      value: base64Encode(bytes),
    );
    return key;
  }
}
