import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/delete_transaction.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late DeleteTransaction useCase;

  setUp(() {
    mockRepo = MockTransactionRepository();
    useCase = DeleteTransaction(mockRepo);
  });

  test('returns Right<Unit> when deletion succeeds', () async {
    when(() => mockRepo.deleteTransaction(transactionId: any(named: 'transactionId')))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase(transactionId: 'tx1');

    expect(result.isRight(), true);
    verify(() => mockRepo.deleteTransaction(transactionId: 'tx1')).called(1);
  });
}
