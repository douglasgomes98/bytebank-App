import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/core/error/failure.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_category.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:bytebank_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/fetch_next_page.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late FetchNextPage useCase;

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
    useCase = FetchNextPage(mockRepo);
  });

  test('returns Right<List> when repository succeeds', () async {
    when(() => mockRepo.fetchNextPage(
          userId: any(named: 'userId'),
          lastTransactionId: any(named: 'lastTransactionId'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => Right(tTransactions));

    final result =
        await useCase(userId: 'user1', lastTransactionId: 'tx0');

    expect(result.isRight(), true);
    expect(result.getOrElse((_) => []).length, 1);
  });

  test('forwards cursor (lastTransactionId) and limit to repository',
      () async {
    when(() => mockRepo.fetchNextPage(
          userId: 'user1',
          lastTransactionId: 'cursor-id',
          limit: 30,
        )).thenAnswer((_) async => Right(tTransactions));

    await useCase(
        userId: 'user1', lastTransactionId: 'cursor-id', limit: 30);

    verify(() => mockRepo.fetchNextPage(
          userId: 'user1',
          lastTransactionId: 'cursor-id',
          limit: 30,
        )).called(1);
  });

  test('returns Left<ServerFailure> on error', () async {
    when(() => mockRepo.fetchNextPage(
          userId: any(named: 'userId'),
          lastTransactionId: any(named: 'lastTransactionId'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => Left(ServerFailure('boom')));

    final result =
        await useCase(userId: 'user1', lastTransactionId: null);

    expect(result.isLeft(), true);
  });
}
