import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/core/error/failure.dart';
import 'package:bytebank_app/features/auth/domain/entities/app_user.dart';
import 'package:bytebank_app/features/auth/domain/usecases/ensure_fresh_session.dart';
import 'package:bytebank_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:bytebank_app/features/auth/providers/auth_providers.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_category.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:bytebank_app/features/transactions/domain/entities/transaction_ui_state.dart';
import 'package:bytebank_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/create_transaction.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/fetch_next_page.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/update_transaction.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/watch_transactions.dart';
import 'package:bytebank_app/features/transactions/presentation/controllers/transaction_notifier.dart';
import 'package:bytebank_app/features/transactions/providers/transaction_providers.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class FakeTransactionEntity extends Fake implements TransactionEntity {}

TransactionEntity _tx(
  String id, {
  DateTime? date,
  double amount = 10.0,
  TransactionType type = TransactionType.income,
}) =>
    TransactionEntity(
      id: id,
      userId: 'user1',
      description: 'tx $id',
      amount: amount,
      type: type,
      category: TransactionCategory.salary,
      date: date ?? DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  late MockTransactionRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FakeTransactionEntity());
  });

  setUp(() {
    mockRepo = MockTransactionRepository();
  });

  AppUser defaultUser() => AppUser(
        id: 'user1',
        name: 'Test',
        email: 'test@test.com',
        balance: 0,
        createdAt: DateTime(2026, 1, 1),
      );

  ProviderContainer makeContainer({AppUser? user, bool noUser = false}) {
    final effectiveUser = noUser ? null : (user ?? defaultUser());
    final controller = StreamController<AppUser?>.broadcast();
    final container = ProviderContainer(
      overrides: [
        authStateStreamProvider.overrideWith((_) {
          scheduleMicrotask(() {
            controller.add(effectiveUser);
          });
          return controller.stream;
        }),
        transactionRepositoryProvider.overrideWithValue(mockRepo),
        watchTransactionsProvider
            .overrideWithValue(WatchTransactions(mockRepo)),
        createTransactionProvider
            .overrideWithValue(CreateTransaction(mockRepo)),
        updateTransactionProvider
            .overrideWithValue(UpdateTransaction(mockRepo)),
        deleteTransactionProvider
            .overrideWithValue(DeleteTransaction(mockRepo)),
        fetchNextPageProvider.overrideWithValue(FetchNextPage(mockRepo)),
        ensureFreshSessionProvider
            .overrideWithValue(_FakeEnsureFreshSession()),
      ],
    );
    addTearDown(() {
      controller.close();
      container.dispose();
    });
    return container;
  }

  Future<TransactionUiState> readSettled(
    ProviderContainer c, {
    bool Function(TransactionUiState s)? until,
  }) async {
    final predicate = until ?? (s) => true;
    for (int i = 0; i < 100; i++) {
      await Future<void>.delayed(Duration.zero);
      final s = c.read(transactionNotifierProvider);
      if (s is AsyncData<TransactionUiState> && predicate(s.value)) {
        return s.value;
      }
    }
    throw StateError(
        'Notifier did not settle (last state: ${c.read(transactionNotifierProvider)})');
  }

  group('initial state', () {
    test('returns empty state when no user', () async {
      final container = makeContainer(noUser: true);
      final state =
          await readSettled(container);

      expect(state.transactions, isEmpty);
      expect(state.hasMore, false);
      expect(state.balance, 0);
    });

    test('loads first page from watchTransactions', () async {
      final txs = [
        _tx('1', date: DateTime(2026, 1, 3)),
        _tx('2', date: DateTime(2026, 1, 2)),
      ];
      when(() => mockRepo.watchTransactions('user1',
              limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.value(Right(txs)));

      final container = makeContainer();
      final state =
          await readSettled(container);

      expect(state.transactions.length, 2);
      expect(state.hasMore, false);
    });

    test('sets hasMore=true when first page is full', () async {
      final txs = List.generate(
        20,
        (i) => _tx('$i', date: DateTime(2026, 1, 1).add(Duration(days: i))),
      );
      when(() => mockRepo.watchTransactions('user1',
              limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.value(Right(txs)));

      final container = makeContainer();
      final state =
          await readSettled(container);

      expect(state.transactions.length, 20);
      expect(state.hasMore, true);
    });
  });

  group('fetchNextPage', () {
    test('appends next page and updates cursor', () async {
      final firstPage = List.generate(
        20,
        (i) => _tx('first-$i',
            date: DateTime(2026, 2, 1).subtract(Duration(days: i))),
      );
      final secondPage = List.generate(
        20,
        (i) => _tx('second-$i',
            date: DateTime(2026, 1, 1).subtract(Duration(days: i))),
      );

      when(() => mockRepo.watchTransactions('user1',
              limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.value(Right(firstPage)));
      when(() => mockRepo.fetchNextPage(
            userId: 'user1',
            lastTransactionId: 'first-19',
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => Right(secondPage));

      final container = makeContainer();
      await readSettled(container);

      await container
          .read(transactionNotifierProvider.notifier)
          .fetchNextPage();

      final state = container.read(transactionNotifierProvider).value!;
      expect(state.transactions.length, 40);
      expect(state.isLoadingMore, false);
    });

    test('does nothing when hasMore is false', () async {
      when(() => mockRepo.watchTransactions('user1',
              limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.value(Right([_tx('1')])));

      final container = makeContainer();
      await readSettled(container);

      await container
          .read(transactionNotifierProvider.notifier)
          .fetchNextPage();

      verifyNever(() => mockRepo.fetchNextPage(
            userId: any(named: 'userId'),
            lastTransactionId: any(named: 'lastTransactionId'),
            limit: any(named: 'limit'),
          ));
    });

    test('sets hasMore=false when next page is empty', () async {
      final firstPage = List.generate(
        20,
        (i) => _tx('$i', date: DateTime(2026, 1, 1).add(Duration(days: i))),
      );
      when(() => mockRepo.watchTransactions('user1',
              limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.value(Right(firstPage)));
      when(() => mockRepo.fetchNextPage(
            userId: any(named: 'userId'),
            lastTransactionId: any(named: 'lastTransactionId'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => const Right([]));

      final container = makeContainer();
      await readSettled(container);
      await container
          .read(transactionNotifierProvider.notifier)
          .fetchNextPage();

      final state = container.read(transactionNotifierProvider).value!;
      expect(state.hasMore, false);
    });

    test('deduplicates by id when next page overlaps', () async {
      final firstPage = List.generate(
        20,
        (i) => _tx('$i', date: DateTime(2026, 2, 1).add(Duration(days: i))),
      );
      final overlap = [
        firstPage.last,
        _tx('new-1', date: DateTime(2026, 1, 5)),
      ];

      when(() => mockRepo.watchTransactions('user1',
              limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.value(Right(firstPage)));
      when(() => mockRepo.fetchNextPage(
            userId: any(named: 'userId'),
            lastTransactionId: any(named: 'lastTransactionId'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => Right(overlap));

      final container = makeContainer();
      await readSettled(container);
      await container
          .read(transactionNotifierProvider.notifier)
          .fetchNextPage();

      final state = container.read(transactionNotifierProvider).value!;
      final ids = state.transactions.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length,
          reason: 'no duplicates allowed');
      expect(ids.contains('new-1'), true);
    });
  });

  group('createTransaction', () {
    test('invokes EnsureFreshSession before create', () async {
      when(() => mockRepo.watchTransactions('user1',
              limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.value(const Right([])));
      when(() => mockRepo.createTransaction(
            transaction: any(named: 'transaction'),
          )).thenAnswer((_) async => const Right(unit));

      final container = makeContainer();
      await readSettled(container);

      final ensure = container.read(ensureFreshSessionProvider)
          as _FakeEnsureFreshSession;

      await container
          .read(transactionNotifierProvider.notifier)
          .createTransaction(_tx('new'));

      expect(ensure.callCount, 1);
      verify(() => mockRepo.createTransaction(
            transaction: any(named: 'transaction'),
          )).called(1);
    });
  });
}

class _FakeEnsureFreshSession implements EnsureFreshSession {
  int callCount = 0;

  @override
  Future<Either<Failure, Unit>> call() async {
    callCount++;
    return const Right(unit);
  }
}
