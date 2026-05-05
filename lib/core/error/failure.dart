/// Hierarquia selada (`sealed`) de tipos de falha expostos pela camada de
/// domínio.
///
/// Um [Failure] é o valor retornado no lado esquerdo de
/// `Either<Failure, T>` por repositórios e casos de uso. É um tipo Dart puro
/// e carrega a informação necessária para que a camada de apresentação
/// renderize um estado de erro, sem expor detalhes de infraestrutura
/// (códigos do Firebase, exceções de rede, etc.).
library;

/// Tipo base de toda falha de domínio.
///
/// As subclasses são seladas (`sealed`) para que a camada de apresentação
/// possa fazer correspondência exaustiva (`switch` sobre um [Failure] é
/// verificado em tempo de compilação).
sealed class Failure {
  /// Cria um [Failure] com a mensagem [message] já localizada para o usuário.
  const Failure(this.message);

  /// Mensagem legível, em português, pronta para ser exibida ao usuário.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Falha disparada por casos de uso de autenticação
/// (login, cadastro, redefinição de senha).
final class AuthFailure extends Failure {
  /// Cria uma [AuthFailure] com [message] e um [code] opcional do Firebase.
  const AuthFailure(super.message, {this.code});

  /// Identificador estável do erro de origem (por exemplo, um código do
  /// Firebase), preservado para que o controller possa decidir entre
  /// fluxos alternativos de UI.
  final String? code;
}

/// Falha disparada quando uma fonte de dados remota retorna um erro ou um
/// payload inesperado.
final class ServerFailure extends Failure {
  /// Cria uma [ServerFailure].
  const ServerFailure(super.message, {this.code});

  /// Código opcional retornado pelo serviço remoto.
  final String? code;
}

/// Falha disparada quando a persistência local/cache falha.
final class CacheFailure extends Failure {
  /// Cria uma [CacheFailure].
  const CacheFailure(super.message);
}

/// Falha disparada quando o dispositivo está offline ou uma requisição não
/// consegue alcançar o endpoint remoto.
final class NetworkFailure extends Failure {
  /// Cria uma [NetworkFailure].
  const NetworkFailure(super.message);
}

/// Falha disparada quando uma validação no nível de domínio falha antes de
/// chegar à camada de dados.
final class ValidationFailure extends Failure {
  /// Cria uma [ValidationFailure].
  const ValidationFailure(super.message);
}

/// Falha disparada quando uma operação de upload/download contra a camada
/// de armazenamento (Storage) falha.
final class StorageFailure extends Failure {
  /// Cria uma [StorageFailure].
  const StorageFailure(super.message);
}

/// Falha genérica para erros inesperados que não se enquadram em uma
/// categoria mais específica.
final class UnknownFailure extends Failure {
  /// Cria uma [UnknownFailure].
  const UnknownFailure(super.message);
}
