/// Hierarquia de exceções de baixo nível lançadas pela camada de dados.
///
/// As fontes de dados (`data sources`) lançam estas exceções quando uma
/// chamada de infraestrutura falha. Os repositórios as capturam e traduzem
/// em valores [Failure], de modo que a camada de domínio não dependa
/// diretamente de Firebase, HTTP ou erros de plataforma.
library;

/// Classe base para qualquer exceção originada na camada de dados.
///
/// O campo [message] carrega uma descrição legível para humanos do erro e
/// o campo opcional [code] carrega um identificador estável (por exemplo,
/// um código de erro do Firebase) que pode ser usado pelo repositório ao
/// mapear a exceção para um [Failure] tipado.
abstract class AppException implements Exception {
  /// Cria uma [AppException] com a [message] informada e o [code] opcional.
  const AppException(this.message, {this.code});

  /// Descrição legível da falha.
  final String message;

  /// Identificador estável opcional (como um código de erro do Firebase).
  final String? code;

  @override
  String toString() => '$runtimeType($code): $message';
}

/// Lançada quando uma operação de autenticação falha
/// (login, cadastro, redefinição de senha).
class AuthException extends AppException {
  /// Cria uma [AuthException].
  const AuthException(super.message, {super.code});
}

/// Lançada quando uma fonte de dados remota (Firestore, REST) falha.
class ServerException extends AppException {
  /// Cria uma [ServerException].
  const ServerException(super.message, {super.code});
}

/// Lançada quando uma operação de cache local ou armazenamento persistente
/// falha.
class CacheException extends AppException {
  /// Cria uma [CacheException].
  const CacheException(super.message, {super.code});
}

/// Lançada quando não há conectividade de rede ou uma requisição expira.
class NetworkException extends AppException {
  /// Cria uma [NetworkException].
  const NetworkException(super.message, {super.code});
}

/// Lançada quando uma operação de upload/download contra a camada de
/// armazenamento (Storage) falha.
class StorageException extends AppException {
  /// Cria uma [StorageException].
  const StorageException(super.message, {super.code});
}
