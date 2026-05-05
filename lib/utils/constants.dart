class AppConstants {
  // Firestore collections
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';

  // Storage paths
  static const String receiptsStoragePath = 'receipts';

  // Shared preferences keys
  static const String themeKey = 'app_theme';

  // Transaction limits
  static const double maxTransactionAmount = 1000000.0;
  static const double minTransactionAmount = 0.01;

  // App info
  static const String appName = 'ByteBank';
  static const String appVersion = '1.0.0';
}
