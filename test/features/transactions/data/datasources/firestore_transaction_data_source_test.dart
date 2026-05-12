import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank_app/features/transactions/data/datasources/firestore_transaction_data_source.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreTransactionDataSource dataSource;

  Future<void> seedTransactions(int count) async {
    for (int i = 0; i < count; i++) {
      await fakeFirestore.collection('transactions').add({
        'userId': 'user1',
        'description': 'tx $i',
        'amount': 10.0 + i,
        'type': 'income',
        'category': 'salary',
        'date': Timestamp.fromDate(DateTime(2026, 1, 1).add(Duration(days: i))),
        'createdAt':
            Timestamp.fromDate(DateTime(2026, 1, 1).add(Duration(days: i))),
      });
    }
  }

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = FirestoreTransactionDataSource(firestore: fakeFirestore);
  });

  group('watchTransactions', () {
    test('returns at most limit items', () async {
      await seedTransactions(25);

      final stream = dataSource.watchTransactions('user1', limit: 20);
      final result = await stream.first;

      expect(result.length, 20);
    });

    test('orders by date descending', () async {
      await seedTransactions(5);

      final stream = dataSource.watchTransactions('user1', limit: 5);
      final result = await stream.first;

      for (int i = 0; i < result.length - 1; i++) {
        expect(
          result[i].date.isAfter(result[i + 1].date),
          true,
          reason: 'expected descending date order',
        );
      }
    });

    test('filters by userId', () async {
      await seedTransactions(3);
      await fakeFirestore.collection('transactions').add({
        'userId': 'other-user',
        'description': 'other',
        'amount': 99.0,
        'type': 'expense',
        'category': 'food',
        'date': Timestamp.now(),
        'createdAt': Timestamp.now(),
      });

      final result =
          await dataSource.watchTransactions('user1', limit: 20).first;

      expect(result.length, 3);
      expect(result.every((t) => t.userId == 'user1'), true);
    });
  });

  group('fetchPage', () {
    test('returns first page when startAfter is null', () async {
      await seedTransactions(25);

      final page = await dataSource.fetchPage('user1', limit: 10);

      expect(page.length, 10);
    });

    test('returns next page after cursor (no duplicates with first page)',
        () async {
      await seedTransactions(25);

      final first = await dataSource.fetchPage('user1', limit: 10);
      final lastSnapshot =
          await dataSource.getDocumentSnapshot(first.last.id);
      final second = await dataSource.fetchPage(
        'user1',
        limit: 10,
        startAfter: lastSnapshot,
      );

      expect(second.length, 10);
      final firstIds = first.map((t) => t.id).toSet();
      final secondIds = second.map((t) => t.id).toSet();
      expect(firstIds.intersection(secondIds).isEmpty, true);
    });

    test('returns empty when cursor is past last document', () async {
      await seedTransactions(5);

      final all = await dataSource.fetchPage('user1', limit: 5);
      final lastSnapshot =
          await dataSource.getDocumentSnapshot(all.last.id);
      final next = await dataSource.fetchPage(
        'user1',
        limit: 10,
        startAfter: lastSnapshot,
      );

      expect(next, isEmpty);
    });
  });

  group('getDocumentSnapshot', () {
    test('returns snapshot for existing document', () async {
      await seedTransactions(1);
      final docs = await dataSource.fetchPage('user1', limit: 1);

      final snap = await dataSource.getDocumentSnapshot(docs.first.id);

      expect(snap, isNotNull);
      expect(snap!.exists, true);
    });

    test('returns null for missing document', () async {
      final snap = await dataSource.getDocumentSnapshot('nonexistent');
      expect(snap, isNull);
    });
  });
}
