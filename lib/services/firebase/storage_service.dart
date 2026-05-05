import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../utils/constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadReceipt({
    required String userId,
    required File file,
  }) async {
    final ext = file.path.split('.').last;
    final fileName = '${_uuid.v4()}.$ext';
    final path = '${AppConstants.receiptsStoragePath}/$userId/$fileName';

    final ref = _storage.ref().child(path);
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  Future<void> deleteReceipt(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // Ignore errors when deleting (file may not exist)
    }
  }
}
