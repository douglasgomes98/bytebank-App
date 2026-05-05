/// Contrato e implementação básica de verificação de conectividade.
///
/// Reservado para o cliente HTTP transversal e os interceptadores descritos
/// no item 7 da proposta arquitetural (clientes adicionais, fixação de
/// certificado e demais preocupações de rede). Esta classe expõe apenas a
/// interface mínima usada pelos repositórios para registrar uma falha do
/// tipo [NetworkFailure] quando o dispositivo está offline.
library;

/// Abstração que descreve a checagem de conectividade do dispositivo.
abstract class NetworkInfo {
  /// Retorna `true` quando o dispositivo possui conectividade ativa.
  Future<bool> get isConnected;
}

/// Implementação otimista padrão.
///
/// Devolve sempre `true` enquanto a verificação real (via
/// `connectivity_plus` ou similar) não é introduzida. Os repositórios
/// podem manter o contrato sem depender de um pacote adicional neste
/// estágio da migração.
class AlwaysOnlineNetworkInfo implements NetworkInfo {
  /// Cria uma [AlwaysOnlineNetworkInfo].
  const AlwaysOnlineNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}
