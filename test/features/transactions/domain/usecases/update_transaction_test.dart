import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/core/error/failure.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_category.dart';
import 'package:bytebank_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/update_transaction.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class FakeTransactionEntity extends Fake implements TransactionEntity {}

void main() {
  late MockTransactionRepository mockRepo;
  late UpdateTransaction useCase;

  setUpAll(() {
    registerFallbackValue(FakeTransactionEntity());
  });

  final tTransaction = TransactionEntity(
    id: 'tx1',
    userId: 'user1',
    description: 'Atualizado',
    amount: 100.0,
    type: TransactionType.expense,
    category: TransactionCategory.food,
    date: DateTime(2026, 5, 1),
    createdAt: DateTime(2026, 5, 1),
  );

  setUp(() {
    mockRepo = MockTransactionRepository();
    useCase = UpdateTransaction(mockRepo);
  });

  test('returns Right<Unit> on success', () async {
    when(() => mockRepo.updateTransaction(transaction: any(named: 'transaction')))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase(transaction: tTransaction);

    expect(result.isRight(), true);
  });

  test('returns Left<ServerFailure> when transaction not found', () async {
    when(() => mockRepo.updateTransaction(transaction: any(named: 'transaction')))
        .thenAnswer((_) async => Left(ServerFailure('not-found')));

    final result = await useCase(transaction: tTransaction);

    expect(result.isLeft(), true);
  });
}
