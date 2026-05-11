import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/core/providers/core_providers.dart';
import 'package:bytebank_app/features/transactions/data/datasources/firebase_storage_data_source.dart';
import 'package:bytebank_app/features/transactions/data/datasources/firestore_transaction_data_source.dart';
import 'package:bytebank_app/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:bytebank_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/create_transaction.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/update_transaction.dart';
import 'package:bytebank_app/features/transactions/domain/usecases/watch_transactions.dart';

part 'transaction_providers.g.dart';

@Riverpod(keepAlive: true)
FirestoreTransactionDataSource firestoreTransactionDataSource(
        FirestoreTransactionDataSourceRef ref) =>
    FirestoreTransactionDataSource(
      firestore: ref.watch(firebaseFirestoreProvider),
    );

@Riverpod(keepAlive: true)
FirebaseStorageDataSource firebaseStorageDataSource(
        FirebaseStorageDataSourceRef ref) =>
    FirebaseStorageDataSource(
      storage: ref.watch(firebaseStorageProvider),
    );

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(TransactionRepositoryRef ref) =>
    TransactionRepositoryImpl(
      firestoreDataSource: ref.watch(firestoreTransactionDataSourceProvider),
      storageDataSource: ref.watch(firebaseStorageDataSourceProvider),
    );

@Riverpod(keepAlive: true)
WatchTransactions watchTransactions(WatchTransactionsRef ref) =>
    WatchTransactions(ref.watch(transactionRepositoryProvider));

@Riverpod(keepAlive: true)
CreateTransaction createTransaction(CreateTransactionRef ref) =>
    CreateTransaction(ref.watch(transactionRepositoryProvider));

@Riverpod(keepAlive: true)
UpdateTransaction updateTransaction(UpdateTransactionRef ref) =>
    UpdateTransaction(ref.watch(transactionRepositoryProvider));

@Riverpod(keepAlive: true)
DeleteTransaction deleteTransaction(DeleteTransactionRef ref) =>
    DeleteTransaction(ref.watch(transactionRepositoryProvider));
