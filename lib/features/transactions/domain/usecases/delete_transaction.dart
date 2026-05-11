import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository _repository;

  const DeleteTransaction(this._repository);

  Future<Either<Failure, Unit>> call({required String transactionId}) =>
      _repository.deleteTransaction(transactionId: transactionId);
}
