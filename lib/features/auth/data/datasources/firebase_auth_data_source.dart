import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../dtos/user_dto.dart';

/// Fonte de dados que encapsula chamadas ao Firebase Authentication e ao
/// documento de usuário correspondente no Firestore.
///
/// Esta classe trabalha exclusivamente com tipos de infraestrutura
/// (`UserCredential`, `DocumentSnapshot`, `UserDto`); nunca conhece
/// entidades de domínio. Em caso de falha, lança [AuthException] ou
/// [ServerException], que são traduzidas em [Failure] pelo repositório.
class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Cria um [FirebaseAuthDataSource]. As instâncias do Firebase podem ser
  /// injetadas para facilitar testes; quando omitidas, são utilizadas as
  /// instâncias padrão.
  FirebaseAuthDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream que reflete as mudanças de autenticação do Firebase.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// UID do usuário atualmente autenticado, ou `null` quando deslogado.
  String? get currentUserId => _auth.currentUser?.uid;

  /// Lê o documento do usuário [userId] e o converte em [UserDto].
  /// Retorna `null` quando o documento não existe.
  Future<UserDto?> fetchUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      if (!doc.exists) return null;
      return UserDto.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro do Firestore', code: e.code);
    }
  }

  /// Realiza a autenticação com [email] e [password] e retorna o
  /// [UserDto] correspondente.
  ///
  /// Lança [AuthException] em caso de credencial inválida e
  /// [ServerException] caso o documento do usuário não seja encontrado.
  Future<UserDto> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await fetchUser(credential.user!.uid);
      if (user == null) {
        throw const ServerException('Usuário não encontrado');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Erro de autenticação', code: e.code);
    }
  }

  /// Cria uma nova conta no Firebase Authentication, persiste o documento
  /// inicial no Firestore e desloga o usuário em seguida (preservando o
  /// fluxo já existente, em que o usuário deve fazer login manualmente
  /// depois de cadastrar-se).
  Future<UserDto> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      final dto = UserDto(
        id: credential.user!.uid,
        name: name,
        email: email,
        balance: 0.0,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(dto.id)
          .set(dto.toMap());

      await _auth.signOut();
      return dto;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Erro de autenticação', code: e.code);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Erro do Firestore', code: e.code);
    }
  }

  /// Encerra a sessão atual no Firebase Authentication.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Erro ao deslogar', code: e.code);
    }
  }

  /// Envia o e-mail de redefinição de senha para [email].
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Erro ao enviar e-mail de redefinição',
        code: e.code,
      );
    }
  }
}
