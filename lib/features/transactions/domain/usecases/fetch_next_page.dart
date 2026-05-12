import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class FetchNextPage {
  final TransactionRepository _repository;

  const FetchNextPage(this._repository);

  Future<Either<Failure, List<TransactionEntity>>> call({
    required String userId,
    required String? lastTransactionId,
    int limit = 20,
  }) =>
      _repository.fetchNextPage(
        userId: userId,
        lastTransactionId: lastTransactionId,
        limit: limit,
      );
}
