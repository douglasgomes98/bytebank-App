/// Configuração centralizada de rotas da aplicação.
///
/// Reservado, conforme o item 8 da proposta arquitetural, para a futura
/// adoção de `go_router`. Enquanto o roteamento permanecer imperativo
/// (via `Navigator.push`), este arquivo expõe apenas as constantes de nome
/// de rota usadas pela camada de apresentação.
library;

/// Nomes simbólicos das rotas conhecidas pela aplicação.
class AppRoutes {
  /// Tela inicial após login (dashboard com saldo e últimas transações).
  static const String dashboard = '/dashboard';

  /// Tela de login.
  static const String login = '/login';

  /// Tela de cadastro.
  static const String register = '/register';

  /// Tela com a listagem completa de transações.
  static const String transactions = '/transactions';

  /// Tela de criação/edição de transação.
  static const String transactionForm = '/transactions/form';

  /// Tela de detalhe de uma transação.
  static const String transactionDetail = '/transactions/detail';

  /// Tela de perfil do usuário.
  static const String profile = '/profile';
}
