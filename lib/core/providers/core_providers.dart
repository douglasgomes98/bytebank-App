import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/core/security/biometric_authenticator.dart';
import 'package:bytebank_app/core/security/crypto_service.dart';
import 'package:bytebank_app/core/security/secure_storage.dart';
import 'package:bytebank_app/features/auth/data/security/aes_gcm_crypto_service.dart';
import 'package:bytebank_app/features/auth/data/security/flutter_secure_storage_adapter.dart';
import 'package:bytebank_app/features/auth/data/security/local_auth_biometric_authenticator.dart';

part 'core_providers.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) =>
    FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
FirebaseStorage firebaseStorage(FirebaseStorageRef ref) =>
    FirebaseStorage.instance;

@Riverpod(keepAlive: true)
SecureStorage secureStorage(SecureStorageRef ref) =>
    FlutterSecureStorageAdapter();

@Riverpod(keepAlive: true)
CryptoService cryptoService(CryptoServiceRef ref) => AesGcmCryptoService();

@Riverpod(keepAlive: true)
BiometricAuthenticator biometricAuthenticator(BiometricAuthenticatorRef ref) =>
    LocalAuthBiometricAuthenticator();
