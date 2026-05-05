import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';

/// Fonte de dados que encapsula o upload e a exclusão de comprovantes no
/// Firebase Storage.
///
/// Lança [StorageException] em caso de falha. A camada de repositório
/// converte essas exceções em [Failure] tipados.
class FirebaseStorageDataSource {
  final FirebaseStorage _storage;
  final Uuid _uuid;

  /// Cria um [FirebaseStorageDataSource]. As instâncias podem ser
  /// injetadas para facilitar testes.
  FirebaseStorageDataSource({FirebaseStorage? storage, Uuid? uuid})
      : _storage = storage ?? FirebaseStorage.instance,
        _uuid = uuid ?? const Uuid();

  /// Envia [file] como comprovante do usuário [userId] e retorna a URL
  /// pública para download.
  Future<String> uploadReceipt({
    required String userId,
    required File file,
  }) async {
    try {
      final ext = file.path.split('.').last;
      final fileName = '${_uuid.v4()}.$ext';
      final path = '${AppConstants.receiptsStoragePath}/$userId/$fileName';
      final ref = _storage.ref().child(path);
      final task = await ref.putFile(file);
      return await task.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(
        e.message ?? 'Erro ao enviar comprovante',
        code: e.code,
      );
    }
  }

  /// Remove o comprovante referenciado por [url], silenciando exceções de
  /// "arquivo inexistente" para preservar o comportamento original.
  Future<void> deleteReceipt(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } on FirebaseException {
      // Falhas de "arquivo inexistente" são ignoradas, replicando o
      // comportamento anterior do `StorageService.deleteReceipt`.
    }
  }
}
