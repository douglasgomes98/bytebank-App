import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../../models/transaction.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User ---

  Future<AppUser?> getUser(String userId) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<void> updateUser(AppUser user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .update(user.toFirestore());
  }

  // --- Transactions ---

  Stream<List<Transaction>> watchTransactions(String userId) {
    return _db
        .collection(AppConstants.transactionsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final transactions = snapshot.docs
              .map((doc) => Transaction.fromFirestore(doc))
              .toList();
          // Sort by date in Dart instead of Firestore to avoid needing a composite index
          transactions.sort((a, b) => b.date.compareTo(a.date));
          return transactions;
        });
  }

  Future<List<Transaction>> getTransactions(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    Query query = _db
        .collection(AppConstants.transactionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true);

    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }
    if (endDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    final snapshot = await query.get();
    return snapshot.docs.map(Transaction.fromFirestore).toList();
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    final ref = await _db
        .collection(AppConstants.transactionsCollection)
        .add(transaction.toFirestore());
    return transaction.copyWith(id: ref.id);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _db
        .collection(AppConstants.transactionsCollection)
        .doc(transaction.id)
        .update(transaction.toFirestore());
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _db
        .collection(AppConstants.transactionsCollection)
        .doc(transactionId)
        .delete();
  }

  Future<Transaction?> getTransaction(String transactionId) async {
    final doc = await _db
        .collection(AppConstants.transactionsCollection)
        .doc(transactionId)
        .get();
    if (!doc.exists) return null;
    return Transaction.fromFirestore(doc);
  }
}
