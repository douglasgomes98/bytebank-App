import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    final appUser = AppUser(
      id: credential.user!.uid,
      name: name,
      email: email,
      balance: 0.0,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(credential.user!.uid)
        .set(appUser.toFirestore());

    // Sign out immediately so user must login manually
    await _auth.signOut();

    return appUser;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(credential.user!.uid)
        .get();

    return AppUser.fromFirestore(doc);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }
}
