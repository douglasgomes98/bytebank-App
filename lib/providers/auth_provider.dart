import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/firebase/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
    } else {
      final appUser = await _authService.getCurrentUser();
      if (appUser != null) {
        _user = appUser;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUp(name: name, email: email, password: password);
      // User created successfully, but logged out
      // User must login manually
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapFirebaseError(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapFirebaseError(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  void updateUser(AppUser user) {
    _user = user;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'E-mail já está em uso';
      case 'invalid-email':
        return 'E-mail inválido';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 'network-request-failed':
        return 'Sem conexão com a internet';
      default:
        return 'Erro de autenticação. Tente novamente';
    }
  }
}
