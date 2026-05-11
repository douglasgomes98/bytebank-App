import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class WatchTransactions {
  final TransactionRepository _repository;

  const WatchTransactions(this._repository);

  Stream<Either<Failure, List<TransactionEntity>>> call(String userId) =>
      _repository.watchTransactions(userId);
}
