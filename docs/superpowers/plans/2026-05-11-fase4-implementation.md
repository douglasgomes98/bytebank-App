# ByteBank Fase 4 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate ByteBank from Provider+ChangeNotifier to Riverpod with code-gen, add go_router declarative routing, rxdart reactive operators, Firestore pagination, performance optimizations, domain unit tests, and Firestore schema validation rules.

**Architecture:** Foundation-first — Riverpod replaces the entire DI and state management layer first; go_router then consumes the auth stream from Riverpod; rxdart and pagination build on top of the stabilized Riverpod providers. All steps are sequential.

**Tech Stack:** Flutter 3.x, Dart 3.x, flutter_riverpod ^2.5, riverpod_annotation ^2.3, riverpod_generator ^2.4, go_router ^14, rxdart ^0.27, mocktail ^1, fake_cloud_firestore ^3, fpdart ^1.1 (already present), Firebase suite (already present).

---

## File Map

### New files
| Path | Responsibility |
|---|---|
| `lib/core/providers/core_providers.dart` | Firebase instances + security layer providers |
| `lib/features/auth/providers/auth_providers.dart` | Auth data source, repo, all use case providers |
| `lib/features/auth/presentation/controllers/auth_notifier.dart` | `AsyncNotifier<AppUser?>` replacing `AuthController` |
| `lib/features/transactions/providers/transaction_providers.dart` | Transaction data source, repo, use case providers |
| `lib/features/transactions/domain/entities/transaction_ui_state.dart` | Value object: list + balance + hasMore |
| `lib/features/transactions/presentation/controllers/transaction_notifier.dart` | `AsyncNotifier<TransactionUiState>` + pagination |
| `lib/features/transactions/presentation/providers/filtered_transactions_provider.dart` | `StreamProvider` combining transactions stream + rxdart filter |
| `lib/features/profile/providers/profile_providers.dart` | Theme data source, repo, use case providers |
| `lib/features/profile/presentation/controllers/theme_notifier.dart` | `Notifier<ThemeMode>` replacing `ThemeController` |
| `lib/core/security/session_lock_notifier.dart` | `Notifier<bool>` replacing `SessionLockController` |
| `lib/core/router/go_router_refresh_notifier.dart` | `ChangeNotifier` wrapper for stream → GoRouter |
| `test/features/auth/domain/usecases/sign_in_test.dart` | Unit test: SignIn |
| `test/features/auth/domain/usecases/sign_up_test.dart` | Unit test: SignUp |
| `test/features/auth/domain/usecases/sign_out_test.dart` | Unit test: SignOut |
| `test/features/auth/domain/usecases/reset_password_test.dart` | Unit test: ResetPassword |
| `test/features/auth/domain/usecases/ensure_fresh_session_test.dart` | Unit test: EnsureFreshSession |
| `test/features/transactions/domain/usecases/create_transaction_test.dart` | Unit test: CreateTransaction |
| `test/features/transactions/domain/usecases/update_transaction_test.dart` | Unit test: UpdateTransaction |
| `test/features/transactions/domain/usecases/delete_transaction_test.dart` | Unit test: DeleteTransaction |
| `test/features/transactions/domain/usecases/watch_transactions_test.dart` | Unit test: WatchTransactions |
| `test/features/profile/domain/usecases/get_theme_mode_test.dart` | Unit test: GetThemeMode |
| `test/features/profile/domain/usecases/set_theme_mode_test.dart` | Unit test: SetThemeMode |

### Modified files
| Path | What changes |
|---|---|
| `pubspec.yaml` | Add riverpod stack, go_router, rxdart; add dev deps; remove provider |
| `lib/main.dart` | Wrap with `ProviderScope`; add Firestore offline settings |
| `lib/app.dart` | Full rewrite: `ConsumerWidget`, `MaterialApp.router`, session lock handling |
| `lib/core/router/app_router.dart` | Full rewrite: `GoRouter` with redirect guard and route tree |
| `lib/features/auth/presentation/screens/login_screen.dart` | `ConsumerWidget`, `ref.watch`, `context.go` navigation |
| `lib/features/auth/presentation/screens/register_screen.dart` | `ConsumerWidget`, `ref.watch`, `context.go` navigation |
| `lib/features/transactions/data/datasources/firestore_transaction_data_source.dart` | Add pagination params |
| `lib/features/transactions/domain/repositories/transaction_repository.dart` | Add `fetchNextPage` signature |
| `lib/features/transactions/data/repositories/transaction_repository_impl.dart` | Implement `fetchNextPage` |
| `lib/features/transactions/presentation/screens/dashboard_screen.dart` | `ConsumerWidget`, `RepaintBoundary` on chart |
| `lib/features/transactions/presentation/screens/transaction_list_screen.dart` | `ConsumerWidget`, search `BehaviorSubject`, pagination trigger, `itemExtent` |
| `lib/features/transactions/presentation/screens/transaction_form_screen.dart` | `ConsumerWidget`, `ref.watch`, `context.go` navigation |
| `lib/features/transactions/presentation/screens/transaction_detail_screen.dart` | `ConsumerWidget`, `ref.watch`, `context.go` navigation |
| `lib/features/profile/presentation/screens/profile_screen.dart` | `ConsumerWidget`, `ref.watch` |
| `firestore.rules` | Add schema validation helper functions |

### Deleted files
| Path | Reason |
|---|---|
| `lib/core/di/dependencies.dart` | Replaced by `@riverpod` annotations |
| `lib/features/auth/presentation/controllers/auth_controller.dart` | Replaced by `auth_notifier.dart` |
| `lib/features/transactions/presentation/controllers/transaction_controller.dart` | Replaced by `transaction_notifier.dart` |
| `lib/features/profile/presentation/controllers/theme_controller.dart` | Replaced by `theme_notifier.dart` |
| `lib/core/security/session_lock_controller.dart` | Replaced by `session_lock_notifier.dart` |

---

## Task 1: Update Dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Open `pubspec.yaml` and replace the `dependencies` and `dev_dependencies` sections**

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # Firebase
  firebase_core: ^3.13.0
  firebase_auth: ^5.5.2
  cloud_firestore: ^5.6.5
  firebase_storage: ^12.4.4
  firebase_app_check: ^0.3.2

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Routing
  go_router: ^14.6.1

  # UI & Charts
  fl_chart: ^0.70.2
  intl: ^0.20.2
  animations: ^2.0.11

  # Image Handling
  image_picker: ^1.1.2
  cached_network_image: ^3.4.1

  # Utils
  uuid: ^4.5.1
  path_provider: ^2.1.5
  shared_preferences: ^2.3.5

  # Functional types
  fpdart: ^1.1.0

  # Reactive operators
  rxdart: ^0.27.7

  # Security
  flutter_secure_storage: ^9.2.2
  local_auth: ^2.3.0
  cryptography: ^2.7.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  flutter_launcher_icons: ^0.14.1
  riverpod_generator: ^2.4.3
  build_runner: ^2.4.13
  mocktail: ^1.0.4
  fake_cloud_firestore: ^3.0.3
```

- [ ] **Step 2: Run pub get**

```bash
flutter pub get
```

Expected: no errors, `pubspec.lock` updated, `provider` no longer listed.

---

## Task 2: Core Firebase & Security Providers

**Files:**
- Create: `lib/core/providers/core_providers.dart`

- [ ] **Step 1: Create `lib/core/providers/core_providers.dart`**

```dart
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
```

- [ ] **Step 2: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `lib/core/providers/core_providers.g.dart` created with no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/core/providers/ pubspec.yaml pubspec.lock
git commit -m "feat: add riverpod deps and core Firebase/security providers"
```

---

## Task 3: Auth Providers + AuthNotifier

**Files:**
- Create: `lib/features/auth/providers/auth_providers.dart`
- Create: `lib/features/auth/presentation/controllers/auth_notifier.dart`
- Delete: `lib/features/auth/presentation/controllers/auth_controller.dart`

- [ ] **Step 1: Create `lib/features/auth/providers/auth_providers.dart`**

```dart
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
    FirebaseAuthDataSource(ref.watch(firebaseAuthProvider));

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) => AuthRepositoryImpl(
      remoteDataSource: ref.watch(firebaseAuthDataSourceProvider),
      secureStorage: ref.watch(secureStorageProvider),
      cryptoService: ref.watch(cryptoServiceProvider),
    );

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
```

- [ ] **Step 2: Create `lib/features/auth/presentation/controllers/auth_notifier.dart`**

```dart
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/features/auth/domain/entities/app_user.dart';
import 'package:bytebank_app/features/auth/providers/auth_providers.dart';

part 'auth_notifier.g.dart';

/// Stream of auth state — consumed by GoRouter redirect and AuthNotifier.
@Riverpod(keepAlive: true)
Stream<AppUser?> authStateStream(AuthStateStreamRef ref) {
  final useCase = ref.watch(watchAuthStateProvider);
  return useCase();
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AppUser?> build() async {
    // Mirror the auth stream into this notifier's state.
    final sub = ref.listen<AsyncValue<AppUser?>>(
      authStateStreamProvider,
      (_, next) => state = next,
    );
    ref.onDispose(sub.close);
    return ref.read(authStateStreamProvider.future);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signInProvider)
        .call(email: email, password: password);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signUpProvider)
        .call(name: name, email: email, password: password);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }

  Future<void> signOut() async {
    await ref.read(signOutProvider).call();
    state = const AsyncData(null);
  }

  Future<void> resetPassword(String email) async {
    await ref.read(resetPasswordProvider).call(email);
  }
}
```

- [ ] **Step 3: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `auth_providers.g.dart` and `auth_notifier.g.dart` generated, no errors.

- [ ] **Step 4: Delete the old controller**

```bash
rm lib/features/auth/presentation/controllers/auth_controller.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/
git commit -m "feat: migrate auth feature to Riverpod AsyncNotifier"
```

---

## Task 4: Session Lock Notifier

**Files:**
- Create: `lib/core/security/session_lock_notifier.dart`
- Delete: `lib/core/security/session_lock_controller.dart`

- [ ] **Step 1: Create `lib/core/security/session_lock_notifier.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/core/providers/core_providers.dart';

part 'session_lock_notifier.g.dart';

@Riverpod(keepAlive: true)
class SessionLockNotifier extends _$SessionLockNotifier {
  @override
  bool build() => false;

  Future<void> lock() async => state = true;

  Future<void> unlock() async {
    final biometric = ref.read(biometricAuthenticatorProvider);
    final authenticated = await biometric.authenticate();
    if (authenticated) state = false;
  }
}
```

- [ ] **Step 2: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `session_lock_notifier.g.dart` created.

- [ ] **Step 3: Delete old controller**

```bash
rm lib/core/security/session_lock_controller.dart
```

- [ ] **Step 4: Commit**

```bash
git add lib/core/security/
git commit -m "feat: migrate SessionLockController to Riverpod Notifier"
```

---

## Task 5: Transactions Providers + TransactionUiState

**Files:**
- Create: `lib/features/transactions/domain/entities/transaction_ui_state.dart`
- Create: `lib/features/transactions/providers/transaction_providers.dart`

- [ ] **Step 1: Create `lib/features/transactions/domain/entities/transaction_ui_state.dart`**

```dart
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';

class TransactionUiState {
  const TransactionUiState({
    required this.transactions,
    required this.balance,
    required this.hasMore,
  });

  final List<TransactionEntity> transactions;
  final double balance;
  final bool hasMore;

  double get totalIncome => transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  TransactionUiState copyWith({
    List<TransactionEntity>? transactions,
    double? balance,
    bool? hasMore,
  }) =>
      TransactionUiState(
        transactions: transactions ?? this.transactions,
        balance: balance ?? this.balance,
        hasMore: hasMore ?? this.hasMore,
      );
}
```

- [ ] **Step 2: Create `lib/features/transactions/providers/transaction_providers.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/core/providers/core_providers.dart';
import 'package:bytebank_app/features/transactions/data/datasources/firebase_storage_data_source.dart';
import 'package:bytebank_app/features/transactions/data/datasources/firestore_transaction_data_source.dart';
import 'package:bytebank_app/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:bytebank_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/create_transaction.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/update_transaction.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/watch_transactions.dart';

part 'transaction_providers.g.dart';

@Riverpod(keepAlive: true)
FirestoreTransactionDataSource firestoreTransactionDataSource(
        FirestoreTransactionDataSourceRef ref) =>
    FirestoreTransactionDataSource(ref.watch(firebaseFirestoreProvider));

@Riverpod(keepAlive: true)
FirebaseStorageDataSource firebaseStorageDataSource(
        FirebaseStorageDataSourceRef ref) =>
    FirebaseStorageDataSource(ref.watch(firebaseStorageProvider));

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(TransactionRepositoryRef ref) =>
    TransactionRepositoryImpl(
      remoteDataSource: ref.watch(firestoreTransactionDataSourceProvider),
      storageDataSource: ref.watch(firebaseStorageDataSourceProvider),
    );

@Riverpod(keepAlive: true)
WatchTransactions watchTransactions(WatchTransactionsRef ref) =>
    WatchTransactions(ref.watch(transactionRepositoryProvider));

@Riverpod(keepAlive: true)
CreateTransaction createTransaction(CreateTransactionRef ref) =>
    CreateTransaction(ref.watch(transactionRepositoryProvider));

@Riverpod(keepAlive: true)
UpdateTransaction updateTransaction(UpdateTransactionRef ref) =>
    UpdateTransaction(ref.watch(transactionRepositoryProvider));

@Riverpod(keepAlive: true)
DeleteTransaction deleteTransaction(DeleteTransactionRef ref) =>
    DeleteTransaction(ref.watch(transactionRepositoryProvider));
```

- [ ] **Step 3: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `transaction_providers.g.dart` created, no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/transactions/
git commit -m "feat: add TransactionUiState and transaction Riverpod providers"
```

---

## Task 6: Profile Providers + ThemeNotifier

**Files:**
- Create: `lib/features/profile/providers/profile_providers.dart`
- Create: `lib/features/profile/presentation/controllers/theme_notifier.dart`
- Delete: `lib/features/profile/presentation/controllers/theme_controller.dart`

- [ ] **Step 1: Create `lib/features/profile/providers/profile_providers.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/features/profile/data/datasources/preferences_data_source.dart';
import 'package:bytebank_app/features/profile/data/repositories/theme_repository_impl.dart';
import 'package:bytebank_app/features/profile/domain/repositories/theme_repository.dart';
import 'package:bytebank_app/features/profile/domain/usecases/get_theme_mode.dart';
import 'package:bytebank_app/features/profile/domain/usecases/set_theme_mode.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
PreferencesDataSource preferencesDataSource(PreferencesDataSourceRef ref) =>
    PreferencesDataSource();

@Riverpod(keepAlive: true)
ThemeRepository themeRepository(ThemeRepositoryRef ref) =>
    ThemeRepositoryImpl(ref.watch(preferencesDataSourceProvider));

@Riverpod(keepAlive: true)
GetThemeMode getThemeMode(GetThemeModeRef ref) =>
    GetThemeMode(ref.watch(themeRepositoryProvider));

@Riverpod(keepAlive: true)
SetThemeMode setThemeMode(SetThemeModeRef ref) =>
    SetThemeMode(ref.watch(themeRepositoryProvider));
```

- [ ] **Step 2: Create `lib/features/profile/presentation/controllers/theme_notifier.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/features/profile/providers/profile_providers.dart';

part 'theme_notifier.g.dart';

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    final result = ref.read(getThemeModeProvider).call();
    return result.fold((_) => ThemeMode.system, (mode) => mode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await ref.read(setThemeModeProvider).call(mode);
    state = mode;
  }
}
```

- [ ] **Step 3: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `profile_providers.g.dart` and `theme_notifier.g.dart` created.

- [ ] **Step 4: Delete old controller**

```bash
rm lib/features/profile/presentation/controllers/theme_controller.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/profile/
git commit -m "feat: migrate profile feature to Riverpod Notifier"
```

---

## Task 7: Update main.dart + ProviderScope

> **Note:** `app.dart` is NOT rewritten here because it depends on `appRouterProvider` defined in Task 8. Rewrite `app.dart` only after completing Task 8.

**Files:**
- Modify: `lib/main.dart`
- Delete: `lib/core/di/dependencies.dart`

- [ ] **Step 1: Rewrite `lib/main.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bytebank_app/app.dart';
import 'package:bytebank_app/core/security/app_check_bootstrap.dart';
import 'package:bytebank_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppCheckBootstrap.activate();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await initializeDateFormatting('pt_BR');

  runApp(const ProviderScope(child: ByteBankApp()));
}
```

- [ ] **Step 2: Delete old composition root**

```bash
rm lib/core/di/dependencies.dart
```

- [ ] **Step 3: Run code generation and verify compile**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

Expected: no errors (fix any remaining imports that reference deleted files).

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart lib/core/di/
git commit -m "feat: wrap app in ProviderScope, add Firestore offline persistence settings"
```

---

## Task 8: go_router Setup + app.dart Final Rewrite

**Files:**
- Create: `lib/core/router/go_router_refresh_notifier.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/app.dart` (final rewrite — depends on `appRouterProvider` from this task)

- [ ] **Step 1: Create `lib/core/router/go_router_refresh_notifier.dart`**

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';

class GoRouterRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshNotifier(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 2: Rewrite `lib/core/router/app_router.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/core/router/go_router_refresh_notifier.dart';
import 'package:bytebank_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:bytebank_app/features/auth/presentation/screens/login_screen.dart';
import 'package:bytebank_app/features/auth/presentation/screens/register_screen.dart';
import 'package:bytebank_app/features/transactions/presentation/screens/dashboard_screen.dart';
import 'package:bytebank_app/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:bytebank_app/features/transactions/presentation/screens/transaction_form_screen.dart';
import 'package:bytebank_app/features/transactions/presentation/screens/transaction_list_screen.dart';
import 'package:bytebank_app/features/profile/presentation/screens/profile_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final notifier = GoRouterRefreshNotifier(
    ref.watch(authStateStreamProvider.stream),
  );
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authAsync = ref.read(authNotifierProvider);
      return authAsync.when(
        loading: () => null,
        error: (_, __) => '/login',
        data: (user) {
          final isLoggedIn = user != null;
          final isOnAuthRoute = state.matchedLocation == '/login' ||
              state.matchedLocation == '/register';
          if (!isLoggedIn && !isOnAuthRoute) return '/login';
          if (isLoggedIn && isOnAuthRoute) return '/dashboard';
          return null;
        },
      );
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(
        path: '/transactions',
        builder: (_, __) => const TransactionListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (_, __) => const TransactionFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) => TransactionDetailScreen(
              transactionId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
}
```

- [ ] **Step 3: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `app_router.g.dart` created.

- [ ] **Step 4: Rewrite `lib/app.dart` to use `MaterialApp.router`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bytebank_app/core/router/app_router.dart';
import 'package:bytebank_app/core/security/session_lock_notifier.dart';
import 'package:bytebank_app/core/theme/app_theme.dart';
import 'package:bytebank_app/features/profile/presentation/controllers/theme_notifier.dart';

class ByteBankApp extends ConsumerWidget {
  const ByteBankApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isLocked = ref.watch(sessionLockNotifierProvider);

    if (isLocked) {
      return MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: _BiometricLockScreen(),
      );
    }

    return MaterialApp.router(
      routerConfig: ref.watch(appRouterProvider),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _BiometricLockScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () =>
              ref.read(sessionLockNotifierProvider.notifier).unlock(),
          child: const Text('Desbloquear com Biometria'),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Update all `Navigator.push` calls to `context.go` in screen files**

In `lib/features/auth/presentation/screens/login_screen.dart`:
- Replace `Navigator.pushReplacementNamed(context, '/dashboard')` → `context.go('/dashboard')`
- Replace `Navigator.pushNamed(context, '/register')` → `context.push('/register')`
- Convert `StatefulWidget` → `ConsumerStatefulWidget` / `StatelessWidget` → `ConsumerWidget`
- Replace `context.watch<AuthController>()` → `ref.watch(authNotifierProvider)`
- Call `ref.read(authNotifierProvider.notifier).signIn(...)` on submit

In `lib/features/auth/presentation/screens/register_screen.dart`:
- Same pattern: `ConsumerWidget`, `ref.watch(authNotifierProvider)`, `context.go('/login')`

In all transaction screens and profile screen:
- Replace `Navigator.*` calls with `context.go(...)` / `context.push(...)` / `context.pop()`
- Replace `context.watch<TransactionController>()` → `ref.watch(transactionNotifierProvider)`
- Replace `context.watch<ThemeController>()` → `ref.watch(themeNotifierProvider)`

- [ ] **Step 6: Run analyze to confirm no Navigator or ChangeNotifier references remain**

```bash
flutter analyze
```

Expected: no errors. Fix any remaining `context.watch<XController>()` or `context.read<XController>()` references.

- [ ] **Step 7: Commit**

```bash
git add lib/core/router/ lib/app.dart lib/features/
git commit -m "feat: add go_router with reactive auth redirect guard, migrate app.dart to MaterialApp.router"
```

---

## Task 9: rxdart + Firestore Pagination

**Files:**
- Modify: `lib/features/transactions/data/datasources/firestore_transaction_data_source.dart`
- Modify: `lib/features/transactions/domain/repositories/transaction_repository.dart`
- Modify: `lib/features/transactions/data/repositories/transaction_repository_impl.dart`
- Create: `lib/features/transactions/presentation/providers/filtered_transactions_provider.dart`
- Create: `lib/features/transactions/presentation/controllers/transaction_notifier.dart`
- Delete: `lib/features/transactions/presentation/controllers/transaction_controller.dart`

### TDD: WatchTransactions + Pagination

- [ ] **Step 1: Write failing test for paginated data source**

Create `test/features/transactions/data/datasources/firestore_transaction_data_source_test.dart`:

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank_app/features/transactions/data/datasources/firestore_transaction_data_source.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreTransactionDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = FirestoreTransactionDataSource(fakeFirestore);
  });

  test('watchTransactions returns at most limit items', () async {
    // seed 25 transactions
    for (int i = 0; i < 25; i++) {
      await fakeFirestore
          .collection('transactions')
          .add({
        'userId': 'user1',
        'description': 'tx $i',
        'amount': 10.0,
        'type': 'income',
        'category': 'salary',
        'date': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    final stream = dataSource.watchTransactions('user1', limit: 20);
    final result = await stream.first;
    expect(result.length, lessThanOrEqualTo(20));
  });
}
```

- [ ] **Step 2: Run test — expect failure**

```bash
flutter test test/features/transactions/data/datasources/firestore_transaction_data_source_test.dart
```

Expected: FAIL — `watchTransactions` does not have a `limit` parameter yet.

- [ ] **Step 3: Update `FirestoreTransactionDataSource` to support pagination**

In `lib/features/transactions/data/datasources/firestore_transaction_data_source.dart`, update `watchTransactions` and add `fetchPage`:

```dart
Stream<List<TransactionDto>> watchTransactions(
  String userId, {
  int limit = 20,
}) {
  return _firestore
      .collection('transactions')
      .where('userId', isEqualTo: userId)
      .orderBy('date', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TransactionDto.fromMap(doc.data(), doc.id))
          .toList());
}

Future<List<TransactionDto>> fetchPage(
  String userId, {
  required DocumentSnapshot lastDocument,
  int limit = 20,
}) async {
  final snapshot = await _firestore
      .collection('transactions')
      .where('userId', isEqualTo: userId)
      .orderBy('date', descending: true)
      .startAfterDocument(lastDocument)
      .limit(limit)
      .get();
  return snapshot.docs
      .map((doc) => TransactionDto.fromMap(doc.data(), doc.id))
      .toList();
}

Future<DocumentSnapshot?> getDocumentSnapshot(
  String userId,
  String lastTransactionId,
) async {
  final doc = await _firestore
      .collection('transactions')
      .doc(lastTransactionId)
      .get();
  return doc.exists ? doc : null;
}
```

- [ ] **Step 4: Run test — expect pass**

```bash
flutter test test/features/transactions/data/datasources/firestore_transaction_data_source_test.dart
```

Expected: PASS.

- [ ] **Step 5: Update `TransactionRepository` interface**

In `lib/features/transactions/domain/repositories/transaction_repository.dart`, add:

```dart
// Add to existing abstract class:
Future<Either<Failure, List<TransactionEntity>>> fetchNextPage(
  String userId,
  String lastTransactionId,
);
```

- [ ] **Step 6: Implement `fetchNextPage` in `TransactionRepositoryImpl`**

In `lib/features/transactions/data/repositories/transaction_repository_impl.dart`:

```dart
@override
Future<Either<Failure, List<TransactionEntity>>> fetchNextPage(
  String userId,
  String lastTransactionId,
) async {
  try {
    final lastDoc = await _remoteDataSource.getDocumentSnapshot(
      userId,
      lastTransactionId,
    );
    if (lastDoc == null) return const Right([]);
    final dtos = await _remoteDataSource.fetchPage(
      userId,
      lastDocument: lastDoc,
    );
    return Right(dtos.map((dto) => dto.toEntity()).toList());
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

- [ ] **Step 7: Add FetchNextPage use case to transaction providers**

In `lib/features/transactions/providers/transaction_providers.dart`, add:

```dart
// Add import:
import 'package:bytebank_app/features/transactions/domain/usecases/fetch_next_page.dart';

// Add provider (keepAlive: true):
@Riverpod(keepAlive: true)
FetchNextPage fetchNextPage(FetchNextPageRef ref) =>
    FetchNextPage(ref.watch(transactionRepositoryProvider));
```

Create `lib/features/transactions/domain/usecases/fetch_next_page.dart`:

```dart
import 'package:fpdart/fpdart.dart';
import 'package:bytebank_app/core/error/failure.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/domain/repositories/transaction_repository.dart';

class FetchNextPage {
  const FetchNextPage(this._repository);
  final TransactionRepository _repository;

  Future<Either<Failure, List<TransactionEntity>>> call({
    required String userId,
    required String lastTransactionId,
  }) =>
      _repository.fetchNextPage(userId, lastTransactionId);
}
```

- [ ] **Step 8: Create filtered transactions StreamProvider**

Create `lib/features/transactions/presentation/providers/filtered_transactions_provider.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bytebank_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_ui_state.dart';
import 'package:bytebank_app/features/transactions/providers/transaction_providers.dart';

part 'filtered_transactions_provider.g.dart';

/// Holds the search query; UI updates this via the notifier.
@riverpod
class TransactionSearchQuery extends _$TransactionSearchQuery {
  final _controller = BehaviorSubject<String>.seeded('');

  @override
  String build() {
    ref.onDispose(_controller.close);
    return '';
  }

  void update(String query) {
    state = query;
    _controller.add(query);
  }

  Stream<String> get debouncedStream =>
      _controller.stream.debounceTime(const Duration(milliseconds: 300));
}

/// Combines transactions stream + debounced search into a single UiState stream.
@riverpod
Stream<TransactionUiState> filteredTransactions(
    FilteredTransactionsRef ref) async* {
  final user = ref.watch(authStateStreamProvider).valueOrNull;
  if (user == null) return;

  final watchUseCase = ref.watch(watchTransactionsProvider);
  final searchNotifier = ref.watch(transactionSearchQueryProvider.notifier);

  final transactionsStream = watchUseCase(user.id)
      .map((result) => result.fold((_) => <TransactionEntity>[], (t) => t));

  yield* Rx.combineLatest2<List<TransactionEntity>, String, TransactionUiState>(
    transactionsStream,
    searchNotifier.debouncedStream.startWith(''),
    (transactions, query) {
      final filtered = query.isEmpty
          ? transactions
          : transactions
              .where((t) =>
                  t.description.toLowerCase().contains(query.toLowerCase()))
              .toList();

      final income = filtered
          .where((t) => t.isIncome)
          .fold<double>(0, (s, t) => s + t.amount);
      final expense = filtered
          .where((t) => t.isExpense)
          .fold<double>(0, (s, t) => s + t.amount);

      return TransactionUiState(
        transactions: filtered,
        balance: income - expense,
        hasMore: transactions.length >= 20,
      );
    },
  );
}
```

- [ ] **Step 9: Create TransactionNotifier with pagination**

Create `lib/features/transactions/presentation/controllers/transaction_notifier.dart`:

```dart
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_ui_state.dart';
import 'package:bytebank_app/features/transactions/presentation/providers/filtered_transactions_provider.dart';
import 'package:bytebank_app/features/transactions/providers/transaction_providers.dart';

part 'transaction_notifier.g.dart';

@Riverpod(keepAlive: true)
class TransactionNotifier extends _$TransactionNotifier {
  @override
  FutureOr<TransactionUiState> build() async {
    final sub = ref.listen<AsyncValue<TransactionUiState>>(
      filteredTransactionsProvider,
      (_, next) => state = next,
    );
    ref.onDispose(sub.close);
    return ref.read(filteredTransactionsProvider.future);
  }

  Future<void> createTransaction(TransactionEntity transaction) async {
    final userId = ref.read(authStateStreamProvider).valueOrNull?.id;
    if (userId == null) return;
    await ref
        .read(createTransactionProvider)
        .call(transaction: transaction.copyWith(userId: userId));
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    await ref.read(updateTransactionProvider).call(transaction: transaction);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await ref
        .read(deleteTransactionProvider)
        .call(transactionId: transactionId);
  }

  Future<void> fetchNextPage() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;

    final userId = ref.read(authStateStreamProvider).valueOrNull?.id;
    if (userId == null) return;

    final lastId = current.transactions.last.id;
    final result = await ref
        .read(fetchNextPageProvider)
        .call(userId: userId, lastTransactionId: lastId);

    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (newItems) {
        final merged = [...current.transactions, ...newItems];
        final income =
            merged.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
        final expense =
            merged.where((t) => t.isExpense).fold<double>(0, (s, t) => s + t.amount);
        state = AsyncData(TransactionUiState(
          transactions: merged,
          balance: income - expense,
          hasMore: newItems.length >= 20,
        ));
      },
    );
  }
}
```

- [ ] **Step 10: Delete old transaction controller**

```bash
rm lib/features/transactions/presentation/controllers/transaction_controller.dart
```

- [ ] **Step 11: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: all `.g.dart` files for new providers created.

- [ ] **Step 12: Update `TransactionListScreen` to use new providers and rxdart search**

In `lib/features/transactions/presentation/screens/transaction_list_screen.dart`:

```dart
// Convert to ConsumerStatefulWidget to hold ScrollController
class TransactionListScreen extends ConsumerStatefulWidget { ... }

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(transactionNotifierProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(transactionNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Transações')),
      body: Column(
        children: [
          TextField(
            onChanged: (q) => ref
                .read(transactionSearchQueryProvider.notifier)
                .update(q),
            decoration: const InputDecoration(
              hintText: 'Buscar transações...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Expanded(
            child: asyncState.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erro: $e'),
              data: (uiState) => ListView.builder(
                controller: _scrollController,
                itemExtent: 72.0,
                itemCount: uiState.transactions.length,
                itemBuilder: (_, i) =>
                    TransactionCard(transaction: uiState.transactions[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 13: Run analyze**

```bash
flutter analyze
```

Expected: no errors.

- [ ] **Step 14: Commit**

```bash
git add lib/features/transactions/
git commit -m "feat: add rxdart filtered stream, Firestore pagination, TransactionNotifier"
```

---

## Task 10: Performance Optimizations

**Files:**
- Modify: `lib/features/transactions/presentation/screens/dashboard_screen.dart`
- Modify: `lib/app.dart`

- [ ] **Step 1: Add `RepaintBoundary` around fl_chart in `DashboardScreen`**

In `lib/features/transactions/presentation/screens/dashboard_screen.dart`, find the `fl_chart` widget (e.g., `BarChart`, `LineChart`, or `PieChart`) and wrap it:

```dart
RepaintBoundary(
  child: SizedBox(
    height: 200,
    child: BarChart(/* existing chart data */),
  ),
),
```

- [ ] **Step 2: Add `precacheImage` in `app.dart`**

In `lib/app.dart`, override `didChangeDependencies` or add to `ByteBankApp.build`:

```dart
// Inside build(), before returning the MaterialApp:
WidgetsBinding.instance.addPostFrameCallback((_) {
  precacheImage(const AssetImage('assets/images/logo.png'), context);
});
```

- [ ] **Step 3: Run `flutter analyze` to find `prefer_const_constructors` warnings**

```bash
flutter analyze 2>&1 | grep prefer_const
```

Fix each reported instance by adding `const` to widget constructors that don't depend on state.

- [ ] **Step 4: Commit**

```bash
git add lib/
git commit -m "perf: add RepaintBoundary, precacheImage, const widgets"
```

---

## Task 11: Domain Unit Tests

**Files:**
- Create: all test files listed in the File Map

### Auth Use Cases

- [ ] **Step 1: Create `test/features/auth/domain/usecases/sign_in_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/core/error/failure.dart';
import 'package:bytebank_app/features/auth/domain/entities/app_user.dart';
import 'package:bytebank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bytebank_app/features/auth/domain/usecases/sign_in.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late SignIn useCase;

  final tUser = AppUser(id: '1', name: 'Test', email: 'test@test.com');

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = SignIn(mockRepo);
  });

  test('returns Right<AppUser> when credentials are valid', () async {
    when(() => mockRepo.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => Right(tUser));

    final result = await useCase(email: 'test@test.com', password: '123456');

    expect(result.isRight(), true);
    expect(result.getOrElse((_) => throw Exception()), tUser);
  });

  test('returns Left<AuthFailure> when credentials are invalid', () async {
    when(() => mockRepo.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => Left(AuthFailure('invalid-credentials')));

    final result = await useCase(email: 'test@test.com', password: 'wrong');

    expect(result.isLeft(), true);
  });
}
```

- [ ] **Step 2: Run sign_in_test — expect pass**

```bash
flutter test test/features/auth/domain/usecases/sign_in_test.dart -v
```

Expected: 2 tests PASS.

- [ ] **Step 3: Create `test/features/auth/domain/usecases/sign_up_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/core/error/failure.dart';
import 'package:bytebank_app/features/auth/domain/entities/app_user.dart';
import 'package:bytebank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bytebank_app/features/auth/domain/usecases/sign_up.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late SignUp useCase;

  final tUser = AppUser(id: '1', name: 'New User', email: 'new@test.com');

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = SignUp(mockRepo);
  });

  test('returns Right<AppUser> on successful registration', () async {
    when(() => mockRepo.signUp(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => Right(tUser));

    final result = await useCase(
        name: 'New User', email: 'new@test.com', password: 'secure123');

    expect(result.isRight(), true);
  });

  test('returns Left<AuthFailure> when email already in use', () async {
    when(() => mockRepo.signUp(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer(
            (_) async => Left(AuthFailure('email-already-in-use')));

    final result = await useCase(
        name: 'New User', email: 'existing@test.com', password: 'secure123');

    expect(result.isLeft(), true);
  });
}
```

- [ ] **Step 4: Create `test/features/auth/domain/usecases/sign_out_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bytebank_app/features/auth/domain/usecases/sign_out.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late SignOut useCase;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = SignOut(mockRepo);
  });

  test('calls repository signOut and returns Right<Unit>', () async {
    when(() => mockRepo.signOut())
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase();

    expect(result.isRight(), true);
    verify(() => mockRepo.signOut()).called(1);
  });
}
```

- [ ] **Step 5: Create `test/features/auth/domain/usecases/reset_password_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/core/error/failure.dart';
import 'package:bytebank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bytebank_app/features/auth/domain/usecases/reset_password.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late ResetPassword useCase;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = ResetPassword(mockRepo);
  });

  test('returns Right<Unit> when email is valid', () async {
    when(() => mockRepo.resetPassword(any()))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase('valid@test.com');

    expect(result.isRight(), true);
  });

  test('returns Left<AuthFailure> when email not found', () async {
    when(() => mockRepo.resetPassword(any()))
        .thenAnswer((_) async => Left(AuthFailure('user-not-found')));

    final result = await useCase('notfound@test.com');

    expect(result.isLeft(), true);
  });
}
```

- [ ] **Step 6: Create `test/features/auth/domain/usecases/ensure_fresh_session_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bytebank_app/features/auth/domain/usecases/ensure_fresh_session.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late EnsureFreshSession useCase;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = EnsureFreshSession(mockRepo);
  });

  test('returns Right<Unit> when session refresh succeeds', () async {
    when(() => mockRepo.ensureFreshSession())
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase();

    expect(result.isRight(), true);
    verify(() => mockRepo.ensureFreshSession()).called(1);
  });
}
```

- [ ] **Step 7: Run all auth tests**

```bash
flutter test test/features/auth/ -v
```

Expected: 7 tests PASS.

### Transaction Use Cases

- [ ] **Step 8: Create `test/features/transactions/domain/usecases/create_transaction_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/core/error/failure.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_category.dart';
import 'package:bytebank_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/create_transaction.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late CreateTransaction useCase;

  final tTransaction = TransactionEntity(
    id: 'tx1',
    userId: 'user1',
    description: 'Salário',
    amount: 5000.0,
    type: TransactionType.income,
    category: TransactionCategory.salary,
    date: DateTime(2026, 5, 1),
    createdAt: DateTime(2026, 5, 1),
  );

  setUp(() {
    mockRepo = MockTransactionRepository();
    useCase = CreateTransaction(mockRepo);
  });

  test('returns Right<Unit> on success', () async {
    when(() => mockRepo.createTransaction(transaction: any(named: 'transaction')))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase(transaction: tTransaction);

    expect(result.isRight(), true);
    verify(() => mockRepo.createTransaction(transaction: tTransaction)).called(1);
  });

  test('returns Left<ServerFailure> on error', () async {
    when(() => mockRepo.createTransaction(transaction: any(named: 'transaction')))
        .thenAnswer((_) async => Left(ServerFailure('error')));

    final result = await useCase(transaction: tTransaction);

    expect(result.isLeft(), true);
  });
}
```

- [ ] **Step 9: Create `test/features/transactions/domain/usecases/update_transaction_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/core/error/failure.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_category.dart';
import 'package:bytebank_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/update_transaction.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late UpdateTransaction useCase;

  final tTransaction = TransactionEntity(
    id: 'tx1',
    userId: 'user1',
    description: 'Atualizado',
    amount: 100.0,
    type: TransactionType.expense,
    category: TransactionCategory.food,
    date: DateTime(2026, 5, 1),
    createdAt: DateTime(2026, 5, 1),
  );

  setUp(() {
    mockRepo = MockTransactionRepository();
    useCase = UpdateTransaction(mockRepo);
  });

  test('returns Right<Unit> on success', () async {
    when(() => mockRepo.updateTransaction(transaction: any(named: 'transaction')))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase(transaction: tTransaction);

    expect(result.isRight(), true);
  });

  test('returns Left<ServerFailure> when transaction not found', () async {
    when(() => mockRepo.updateTransaction(transaction: any(named: 'transaction')))
        .thenAnswer((_) async => Left(ServerFailure('not-found')));

    final result = await useCase(transaction: tTransaction);

    expect(result.isLeft(), true);
  });
}
```

- [ ] **Step 10: Create `test/features/transactions/domain/usecases/delete_transaction_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/delete_transaction.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late DeleteTransaction useCase;

  setUp(() {
    mockRepo = MockTransactionRepository();
    useCase = DeleteTransaction(mockRepo);
  });

  test('returns Right<Unit> when deletion succeeds', () async {
    when(() => mockRepo.deleteTransaction(transactionId: any(named: 'transactionId')))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase(transactionId: 'tx1');

    expect(result.isRight(), true);
    verify(() => mockRepo.deleteTransaction(transactionId: 'tx1')).called(1);
  });
}
```

- [ ] **Step 11: Create `test/features/transactions/domain/usecases/watch_transactions_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_category.dart';
import 'package:bytebank_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/watch_transactions.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late WatchTransactions useCase;

  final tTransactions = [
    TransactionEntity(
      id: 'tx1',
      userId: 'user1',
      description: 'Salário',
      amount: 5000.0,
      type: TransactionType.income,
      category: TransactionCategory.salary,
      date: DateTime(2026, 5, 1),
      createdAt: DateTime(2026, 5, 1),
    ),
  ];

  setUp(() {
    mockRepo = MockTransactionRepository();
    useCase = WatchTransactions(mockRepo);
  });

  test('emits Right<List<TransactionEntity>> from stream', () async {
    when(() => mockRepo.watchTransactions('user1'))
        .thenAnswer((_) => Stream.value(Right(tTransactions)));

    final stream = useCase('user1');
    final result = await stream.first;

    expect(result.isRight(), true);
    expect(result.getOrElse((_) => []).length, 1);
  });
}
```

- [ ] **Step 12: Run all transaction tests**

```bash
flutter test test/features/transactions/ -v
```

Expected: all tests PASS.

### Profile Use Cases

- [ ] **Step 13: Create `test/features/profile/domain/usecases/get_theme_mode_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/features/profile/domain/repositories/theme_repository.dart';
import 'package:bytebank_app/features/profile/domain/usecases/get_theme_mode.dart';

class MockThemeRepository extends Mock implements ThemeRepository {}

void main() {
  late MockThemeRepository mockRepo;
  late GetThemeMode useCase;

  setUp(() {
    mockRepo = MockThemeRepository();
    useCase = GetThemeMode(mockRepo);
  });

  test('returns Right<ThemeMode> from repository', () {
    when(() => mockRepo.getThemeMode())
        .thenReturn(const Right(ThemeMode.dark));

    final result = useCase.call();

    expect(result.isRight(), true);
    expect(result.getOrElse((_) => ThemeMode.system), ThemeMode.dark);
  });
}
```

- [ ] **Step 14: Create `test/features/profile/domain/usecases/set_theme_mode_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/features/profile/domain/repositories/theme_repository.dart';
import 'package:bytebank_app/features/profile/domain/usecases/set_theme_mode.dart';

class MockThemeRepository extends Mock implements ThemeRepository {}

void main() {
  late MockThemeRepository mockRepo;
  late SetThemeMode useCase;

  setUp(() {
    mockRepo = MockThemeRepository();
    useCase = SetThemeMode(mockRepo);
  });

  test('calls repository and returns Right<Unit>', () async {
    when(() => mockRepo.setThemeMode(any()))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase.call(ThemeMode.dark);

    expect(result.isRight(), true);
    verify(() => mockRepo.setThemeMode(ThemeMode.dark)).called(1);
  });
}
```

- [ ] **Step 15: Run all tests**

```bash
flutter test test/ -v
```

Expected: all 11 domain tests PASS.

- [ ] **Step 16: Commit**

```bash
git add test/
git commit -m "test: add domain unit tests for auth, transactions, and profile use cases"
```

---

## Task 12: Firestore Rules Schema Validation

**Files:**
- Modify: `firestore.rules`

- [ ] **Step 1: Update `firestore.rules` to add validation helper functions**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isValidTransaction(data) {
      return data.amount is number
        && data.amount > 0
        && data.description is string
        && data.description.size() > 0
        && data.description.size() <= 500
        && data.type in ['income', 'expense', 'transfer']
        && data.userId == request.auth.uid;
    }

    function isValidUser(data) {
      return data.name is string
        && data.name.size() > 0
        && data.email is string;
    }

    match /users/{userId} {
      allow read: if isAuthenticated() && isOwner(userId);
      allow create: if isAuthenticated() && isOwner(userId)
        && isValidUser(request.resource.data);
      allow update: if isAuthenticated() && isOwner(userId)
        && isValidUser(request.resource.data);
      allow delete: if isAuthenticated() && isOwner(userId);
    }

    match /transactions/{transactionId} {
      allow read: if isAuthenticated()
        && isOwner(resource.data.userId);
      allow create: if isAuthenticated()
        && isValidTransaction(request.resource.data);
      allow update: if isAuthenticated()
        && isOwner(resource.data.userId)
        && isValidTransaction(request.resource.data);
      allow delete: if isAuthenticated()
        && isOwner(resource.data.userId);
    }
  }
}
```

- [ ] **Step 2: Deploy rules**

```bash
firebase deploy --only firestore:rules
```

Expected: `Deploy complete!`

- [ ] **Step 3: Commit**

```bash
git add firestore.rules
git commit -m "feat: add schema validation to Firestore security rules"
```

---

## Final Verification

- [ ] **Run full test suite**

```bash
flutter test -v
```

Expected: all tests PASS.

- [ ] **Run static analysis**

```bash
flutter analyze
```

Expected: no errors.

- [ ] **Build debug to confirm app runs**

```bash
flutter run --debug
```

Expected: app launches, login flow works, transactions list renders with pagination.
