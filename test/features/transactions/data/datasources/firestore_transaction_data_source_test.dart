import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank_app/features/transactions/data/datasources/firestore_transaction_data_source.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreTransactionDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = FirestoreTransactionDataSource(firestore: fakeFirestore);
  });

  test('watchTransactions returns at most limit items', () async {
    final now = Timestamp.now();
    for (int i = 0; i < 25; i++) {
      await fakeFirestore.collection('transactions').add({
        'userId': 'user1',
        'description': 'tx $i',
        'amount': 10.0,
        'type': 'income',
        'category': 'salary',
        'date': now,
        'createdAt': now,
      });
    }

    final stream = dataSource.watchTransactions('user1', limit: 20);
    final result = await stream.first;
    expect(result.length, lessThanOrEqualTo(20));
  });
}
