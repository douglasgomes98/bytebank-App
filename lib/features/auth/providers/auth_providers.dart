import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/core/providers/core_providers.dart';
import 'package:bytebank_app/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:bytebank_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bytebank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bytebank_app/features/auth/domain/usecases/ensure_fresh_session.dart';
import 'package:bytebank_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:bytebank_app/features/auth/domain/usecases/reset_password.dart';
import 'package:bytebank_app/features/auth/domain/usecases/sign_in.dart';
import 'package:bytebank_app/features/auth/domain/usecases/sign_out.dart';
import 'package:bytebank_app/features/auth/domain/usecases/sign_up.dart';
import 'package:bytebank_app/features/auth/domain/usecases/watch_auth_state.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuthDataSource firebaseAuthDataSource(FirebaseAuthDataSourceRef ref) =>
    FirebaseAuthDataSource(
      auth: ref.watch(firebaseAuthProvider),
      firestore: ref.watch(firebaseFirestoreProvider),
    );

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) =>
    AuthRepositoryImpl(ref.watch(firebaseAuthDataSourceProvider));

@Riverpod(keepAlive: true)
SignIn signIn(SignInRef ref) => SignIn(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
SignUp signUp(SignUpRef ref) => SignUp(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
SignOut signOut(SignOutRef ref) => SignOut(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
ResetPassword resetPassword(ResetPasswordRef ref) =>
    ResetPassword(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
GetCurrentUser getCurrentUser(GetCurrentUserRef ref) =>
    GetCurrentUser(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
WatchAuthState watchAuthState(WatchAuthStateRef ref) =>
    WatchAuthState(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
EnsureFreshSession ensureFreshSession(EnsureFreshSessionRef ref) =>
    EnsureFreshSession(ref.watch(authRepositoryProvider));
