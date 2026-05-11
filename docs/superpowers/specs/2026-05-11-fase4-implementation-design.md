# ByteBank Fase 4 — Implementation Design

**Date:** 2026-05-11
**Approach:** Foundation First (A)
**Scope:** Riverpod migration → go_router → rxdart + pagination → performance → domain tests → Firestore rules

---

## Context

Clean Architecture (feature-first) was implemented in Fase 3. This spec covers what remains for Fase 4: advanced state management (Riverpod), declarative routing (go_router), reactive operators (rxdart), Firestore pagination, performance optimizations, domain unit tests, and Firestore schema validation rules.

**What stays unchanged:** domain entities, repository interfaces, use cases, DTOs, data sources, security layer (flutter_secure_storage, cryptography, local_auth, firebase_app_check), fpdart Either/Failure contracts.

---

## Step 1 — Riverpod Migration

### Dependencies delta

```yaml
# Add
flutter_riverpod: ^2.5.x
riverpod_annotation: ^2.3.x

# Dev
riverpod_generator: ^2.4.x
build_runner: ^2.4.x

# Remove
provider: ^6.1.2
```

### Breaking changes

| Before | After |
|---|---|
| `MultiProvider` in `app.dart` | `ProviderScope` wrapping `ByteBankApp` in `main.dart` |
| `core/di/dependencies.dart` composition root | `@riverpod` annotations co-located with each repository/use case |
| `ChangeNotifier` controllers | `AsyncNotifier` / `Notifier` per feature |
| `context.watch<AuthController>()` | `ref.watch(authNotifierProvider)` |

### Controllers

**`AuthNotifier extends AsyncNotifier<AppUser?>`**
- State: `AsyncValue<AppUser?>`
- Watches `watchAuthStateProvider` stream on build
- Methods: `signIn()`, `signUp()`, `signOut()`, `resetPassword()`, `updateUser()`

**`TransactionNotifier extends AsyncNotifier<TransactionUiState>`**
- State: `AsyncValue<TransactionUiState>` (list + balance + hasMore + lastDoc)
- Delegates to filtered stream (see Step 3)
- Methods: `createTransaction()`, `updateTransaction()`, `deleteTransaction()`, `fetchNextPage()`

**`ThemeNotifier extends Notifier<ThemeMode>`**
- State: `ThemeMode`
- Methods: `setThemeMode(ThemeMode)`

**`SessionLockNotifier extends Notifier<bool>`**
- Replaces `SessionLockController ChangeNotifier`

### Provider declarations (pattern)

```dart
@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) =>
    AuthRepositoryImpl(ref.watch(firebaseAuthDataSourceProvider), ...);

@riverpod
SignIn signIn(SignInRef ref) => SignIn(ref.watch(authRepositoryProvider));
```

Repositories: `keepAlive: true`. Use cases: auto-dispose (default).

### `app.dart`

- `MaterialApp` → `MaterialApp.router` (see Step 2)
- `_AuthGate`: `ref.watch(authNotifierProvider)` drives routing
- `_BiometricLockScreen`: `ref.watch(sessionLockNotifierProvider)`
- Theme: `ref.watch(themeNotifierProvider)`

---

## Step 2 — go_router

### Dependency

```yaml
go_router: ^14.x
```

### Route tree

```
/login
/register
/dashboard
/transactions          → TransactionListScreen
/transactions/new      → TransactionFormScreen
/transactions/:id      → TransactionDetailScreen
/profile
```

### `core/router/app_router.dart`

```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = GoRouterRefreshNotifier(
    ref.watch(authNotifierProvider.stream),
  );
  return GoRouter(
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final isLoggedIn = auth.valueOrNull != null;
      if (!isLoggedIn) return '/login';
      if (state.matchedLocation == '/login') return '/dashboard';
      return null;
    },
    routes: [...],
  );
});
```

`GoRouterRefreshNotifier`: thin `ChangeNotifier` wrapper that calls `notifyListeners()` on each stream event — required by `refreshListenable`.

### Navigation

All `Navigator.push` / `Navigator.pushReplacementNamed` calls replaced with `context.go(...)` / `context.push(...)`.

---

## Step 3 — rxdart + Firestore Pagination

### Dependency

```yaml
rxdart: ^0.27.x
```

### Pagination

`FirestoreTransactionDataSource` changes:
- `watchTransactions(userId)` → `watchTransactions(userId, {DocumentSnapshot? startAfter})` with `.limit(20)`
- New method: `fetchPage(userId, lastDoc)` returns `Future<List<TransactionDto>>`

`TransactionRepository` adds:
- `Future<Either<Failure, List<TransactionEntity>>> fetchNextPage(String userId, DocumentSnapshot lastDoc)`

`TransactionUiState` (new value object):
```dart
class TransactionUiState {
  final List<TransactionEntity> transactions;
  final double balance;
  final bool hasMore;
  final DocumentSnapshot? lastDoc;
}
```

### rxdart operators

In `TransactionNotifier` (or dedicated `filteredTransactionsProvider`):

```dart
// Search field debounce
final _searchController = BehaviorSubject<String>.seeded('');
Stream<String> get searchStream =>
    _searchController.stream.debounceTime(const Duration(milliseconds: 300));

// Combine transactions stream + filter stream
Rx.combineLatest2(
  transactionsStream,
  searchStream,
  (transactions, query) => _applyFilter(transactions, query),
)

// Period selector: switchMap cancels previous query
periodStream.switchMap((period) => watchTransactionsForPeriod(period))
```

### StreamProvider

```dart
@riverpod
Stream<TransactionUiState> filteredTransactions(FilteredTransactionsRef ref) {
  // combines watchTransactions stream + search/period filters via rxdart
}
```

Consumed in UI as `ref.watch(filteredTransactionsProvider)` → `AsyncValue<TransactionUiState>`.

---

## Step 4 — Performance

### Firestore offline persistence

In `main.dart`, after `Firebase.initializeApp(...)`:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

Writes made offline are queued locally and synced automatically on reconnect — online behavior unchanged.

### Query pre-warming

`TransactionNotifier.build()` subscribes to the transactions stream immediately after auth, before the user navigates to the list screen.

### `precacheImage`

In `_AuthGate` (or dedicated splash), before rendering first screen:
```dart
await precacheImage(const AssetImage('assets/images/logo.png'), context);
```

### `RepaintBoundary`

Wrap `fl_chart` widget in `DashboardScreen`:
```dart
RepaintBoundary(child: BalanceChart(...))
```

### `ListView.builder` with `itemExtent`

`TransactionListScreen` list uses fixed-height rows:
```dart
ListView.builder(
  itemExtent: 72.0,
  itemCount: transactions.length,
  itemBuilder: (_, i) => TransactionCard(transactions[i]),
)
```

### `const` audit

Run `flutter analyze` and resolve all `prefer_const_constructors` warnings in static widgets.

---

## Step 5 — Domain Unit Tests

### Dependencies (dev)

```yaml
mocktail: ^1.x
fake_cloud_firestore: ^3.x
```

### Structure

```
test/
  features/
    auth/domain/usecases/
      sign_in_test.dart
      sign_up_test.dart
      sign_out_test.dart
      reset_password_test.dart
      ensure_fresh_session_test.dart
    transactions/domain/usecases/
      create_transaction_test.dart
      update_transaction_test.dart
      delete_transaction_test.dart
      watch_transactions_test.dart
    profile/domain/usecases/
      get_theme_mode_test.dart
      set_theme_mode_test.dart
```

### Pattern per test file

```dart
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late SignIn useCase;

  setUp(() {
    repo = MockAuthRepository();
    useCase = SignIn(repo);
  });

  test('returns Right<AppUser> on valid credentials', () async {
    when(() => repo.signIn(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => Right(fakeUser));
    final result = await useCase(email: 'a@b.com', password: '123456');
    expect(result.isRight(), true);
  });

  test('returns Left<AuthFailure> on invalid credentials', () async {
    when(() => repo.signIn(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => Left(AuthFailure('invalid')));
    final result = await useCase(email: 'a@b.com', password: 'wrong');
    expect(result.isLeft(), true);
  });
}
```

No Flutter imports. No Firebase. Pure Dart.

---

## Step 6 — Firestore Rules Schema Validation

Add field validation to existing `firestore.rules`.

### Transactions — create & update

```javascript
function isValidTransaction(data) {
  return data.amount is number
    && data.amount > 0
    && data.description is string
    && data.description.size() > 0
    && data.description.size() <= 500
    && data.type in ['income', 'expense', 'transfer']
    && data.userId == request.auth.uid;
}
```

Apply in `allow create, update: if isValidTransaction(request.resource.data);`

### Users — create & update

```javascript
function isValidUser(data) {
  return data.name is string
    && data.name.size() > 0
    && data.email is string;
}
```

Apply in `allow create, update: if isValidUser(request.resource.data);`

Storage rules unchanged.

Deploy: `firebase deploy --only firestore:rules`

---

## Dependencies Summary

| Action | Package | Version |
|---|---|---|
| Add | `flutter_riverpod` | `^2.5.x` |
| Add | `riverpod_annotation` | `^2.3.x` |
| Add | `go_router` | `^14.x` |
| Add | `rxdart` | `^0.27.x` |
| Add (dev) | `riverpod_generator` | `^2.4.x` |
| Add (dev) | `build_runner` | `^2.4.x` |
| Add (dev) | `mocktail` | `^1.x` |
| Add (dev) | `fake_cloud_firestore` | `^3.x` |
| Remove | `provider` | — |
