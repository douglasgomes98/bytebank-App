import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_category.dart';
import 'package:bytebank_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/watch_transactions.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late WatchTransactions useCase;

  final tTransactions = [
    TransactionEntity(
      id: 'tx1',
      userId: 'user1',
      description: 'Salário',
      amount: 5000.0,
      type: TransactionType.income,
      category: TransactionCategory.salary,
      date: DateTime(2026, 5, 1),
      createdAt: DateTime(2026, 5, 1),
    ),
  ];

  setUp(() {
    mockRepo = MockTransactionRepository();
    useCase = WatchTransactions(mockRepo);
  });

  test('emits Right<List<TransactionEntity>> from stream', () async {
    when(() => mockRepo.watchTransactions('user1'))
        .thenAnswer((_) => Stream.value(Right(tTransactions)));

    final stream = useCase('user1');
    final result = await stream.first;

    expect(result.isRight(), true);
    expect(result.getOrElse((_) => []).length, 1);
  });
}
