import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Caso de uso que expõe o [Stream] de transações de um usuário.
///
/// Usar streams em vez de futuros para esta operação preserva a
/// reatividade já fornecida pelos snapshots do Firestore e abre caminho
/// para a composição com operadores reativos descrita no item 7 da
/// proposta arquitetural.
class WatchTransactions {
  final TransactionRepository _repository;

  /// Cria um caso de uso ligado a [_repository].
  const WatchTransactions(this._repository);

  /// Retorna o stream de transações pertencentes ao usuário [userId].
  Stream<List<TransactionEntity>> call(String userId) =>
      _repository.watchTransactions(userId);
}
