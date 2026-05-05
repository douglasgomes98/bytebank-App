import '../../features/auth/data/datasources/firebase_auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/reset_password.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/profile/data/datasources/preferences_data_source.dart';
import '../../features/profile/data/repositories/theme_repository_impl.dart';
import '../../features/profile/domain/repositories/theme_repository.dart';
import '../../features/profile/domain/usecases/get_theme_mode.dart';
import '../../features/profile/domain/usecases/set_theme_mode.dart';
import '../../features/profile/presentation/controllers/theme_controller.dart';
import '../../features/transactions/data/datasources/firebase_storage_data_source.dart';
import '../../features/transactions/data/datasources/firestore_transaction_data_source.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/create_transaction.dart';
import '../../features/transactions/domain/usecases/delete_transaction.dart';
import '../../features/transactions/domain/usecases/update_transaction.dart';
import '../../features/transactions/domain/usecases/watch_transactions.dart';
import '../../features/transactions/presentation/controllers/transaction_controller.dart';

/// Composition root da aplicação.
///
/// Concentra a montagem das árvores de objetos das três features (auth,
/// transactions, profile), expondo apenas os controllers prontos para
/// serem fornecidos à árvore de widgets via `MultiProvider`. Equivale,
/// neste estágio, ao papel descrito em `core/di/` da proposta
/// arquitetural (item 4) — utilizando construtores explícitos em vez de
/// um container externo.
class AppDependencies {
  // -------- Auth --------
  late final FirebaseAuthDataSource _authDataSource =
      FirebaseAuthDataSource();
  late final AuthRepository _authRepository =
      AuthRepositoryImpl(_authDataSource);

  /// Caso de uso de login pré-configurado.
  late final SignIn signInUseCase = SignIn(_authRepository);

  /// Caso de uso de cadastro pré-configurado.
  late final SignUp signUpUseCase = SignUp(_authRepository);

  /// Caso de uso de logout pré-configurado.
  late final SignOut signOutUseCase = SignOut(_authRepository);

  /// Caso de uso de recuperação de senha pré-configurado.
  late final ResetPassword resetPasswordUseCase =
      ResetPassword(_authRepository);

  /// Caso de uso de leitura do usuário atual pré-configurado.
  late final GetCurrentUser getCurrentUserUseCase =
      GetCurrentUser(_authRepository);

  /// Caso de uso reativo do estado de autenticação pré-configurado.
  late final WatchAuthState watchAuthStateUseCase =
      WatchAuthState(_authRepository);

  // -------- Transactions --------
  late final FirestoreTransactionDataSource _transactionDataSource =
      FirestoreTransactionDataSource();
  late final FirebaseStorageDataSource _storageDataSource =
      FirebaseStorageDataSource();
  late final TransactionRepository _transactionRepository =
      TransactionRepositoryImpl(
    firestoreDataSource: _transactionDataSource,
    storageDataSource: _storageDataSource,
  );

  /// Caso de uso reativo da listagem de transações pré-configurado.
  late final WatchTransactions watchTransactionsUseCase =
      WatchTransactions(_transactionRepository);

  /// Caso de uso de criação de transação pré-configurado.
  late final CreateTransaction createTransactionUseCase =
      CreateTransaction(_transactionRepository);

  /// Caso de uso de atualização de transação pré-configurado.
  late final UpdateTransaction updateTransactionUseCase =
      UpdateTransaction(_transactionRepository);

  /// Caso de uso de exclusão de transação pré-configurado.
  late final DeleteTransaction deleteTransactionUseCase =
      DeleteTransaction(_transactionRepository);

  // -------- Profile (Theme) --------
  late final PreferencesDataSource _preferencesDataSource =
      PreferencesDataSource();
  late final ThemeRepository _themeRepository =
      ThemeRepositoryImpl(_preferencesDataSource);

  /// Caso de uso de leitura da preferência de tema pré-configurado.
  late final GetThemeMode getThemeModeUseCase =
      GetThemeMode(_themeRepository);

  /// Caso de uso de gravação da preferência de tema pré-configurado.
  late final SetThemeMode setThemeModeUseCase =
      SetThemeMode(_themeRepository);

  // -------- Controllers (presentation) --------

  /// Cria um [AuthController] novo já ligado aos casos de uso.
  AuthController buildAuthController() => AuthController(
        signIn: signInUseCase,
        signUp: signUpUseCase,
        signOut: signOutUseCase,
        resetPassword: resetPasswordUseCase,
        getCurrentUser: getCurrentUserUseCase,
        watchAuthState: watchAuthStateUseCase,
      );

  /// Cria um [TransactionController] novo já ligado aos casos de uso.
  TransactionController buildTransactionController() => TransactionController(
        watchTransactions: watchTransactionsUseCase,
        createTransaction: createTransactionUseCase,
        updateTransaction: updateTransactionUseCase,
        deleteTransaction: deleteTransactionUseCase,
      );

  /// Cria um [ThemeController] novo já ligado aos casos de uso.
  ThemeController buildThemeController() => ThemeController(
        getThemeMode: getThemeModeUseCase,
        setThemeMode: setThemeModeUseCase,
      );
}
