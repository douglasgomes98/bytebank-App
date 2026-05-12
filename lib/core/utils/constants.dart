/// Constantes globais da aplicação (nomes de coleções, caminhos de
/// armazenamento e limites de valor).
class AppConstants {
  /// Nome da coleção do Firestore que armazena os documentos `AppUser`.
  static const String usersCollection = 'users';

  /// Nome da coleção do Firestore que armazena os documentos de transação.
  static const String transactionsCollection = 'transactions';

  /// Caminho raiz dentro do Firebase Storage onde as imagens de
  /// comprovante são enviadas.
  static const String receiptsStoragePath = 'receipts';

  /// Chave usada para persistir o tema selecionado pelo usuário.
  static const String themeKey = 'app_theme';

  /// Valor máximo permitido para uma única transação (em reais).
  static const double maxTransactionAmount = 1000000.0;

  /// Valor mínimo permitido para uma única transação (em reais).
  static const double minTransactionAmount = 0.01;

  /// Nome público da aplicação.
  static const String appName = 'ByteBank';

  /// Versão atual da aplicação, exibida na tela de perfil.
  static const String appVersion = '1.0.0';

  /// Tamanho da página usada nas consultas paginadas de transações.
  static const int transactionsPageSize = 20;
}
