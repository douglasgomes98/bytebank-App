import '../../features/auth/data/datasources/firebase_auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/security/aes_gcm_crypto_service.dart';
import '../../features/auth/data/security/flutter_secure_storage_adapter.dart';
import '../../features/auth/data/security/local_auth_biometric_authenticator.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/ensure_fresh_session.dart';
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
import '../security/biometric_authenticator.dart';
import '../security/crypto_service.dart';
import '../security/secure_storage.dart';
import '../security/session_lock_controller.dart';

/// Composition root da aplicação.
///
/// Concentra a montagem das árvores de objetos das três features (auth,
/// transactions, profile) e dos serviços transversais de segurança,
/// expondo apenas os controllers prontos para serem fornecidos à árvore
/// de widgets via `MultiProvider`.
class AppDependencies {
  // -------- Security (transversal) --------
  late final SecureStorage _secureStorage = FlutterSecureStorageAdapter();

  /// Serviço de criptografia simétrica disponível para qualquer feature
  /// que precise cifrar dados sensíveis em cache local.
  late final CryptoService cryptoService =
      AesGcmCryptoService(secureStorage: _secureStorage);

  /// Autenticador biométrico do dispositivo.
  late final BiometricAuthenticator biometricAuthenticator =
      LocalAuthBiometricAuthenticator();

  /// Controlador de bloqueio de sessão por biometria.
  late final SessionLockController sessionLockController =
      SessionLockController(
    secureStorage: _secureStorage,
    authenticator: biometricAuthenticator,
  );

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

  /// Caso de uso de revalidação de sessão pré-configurado.
  late final EnsureFreshSession ensureFreshSessionUseCase =
      EnsureFreshSession(_authRepository);

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
  late final CreateTransaction createTransactionUseCase = CreateTransaction(
    _transactionRepository,
    ensureFreshSessionUseCase,
  );

  /// Caso de uso de atualização de transação pré-configurado.
  late final UpdateTransaction updateTransactionUseCase = UpdateTransaction(
    _transactionRepository,
    ensureFreshSessionUseCase,
  );

  /// Caso de uso de exclusão de transação pré-configurado.
  late final DeleteTransaction deleteTransactionUseCase = DeleteTransaction(
    _transactionRepository,
    ensureFreshSessionUseCase,
  );

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
        secureStorage: _secureStorage,
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
