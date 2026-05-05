import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/firebase/firestore_service.dart';
import '../services/firebase/storage_service.dart';
import 'package:uuid/uuid.dart';

enum TransactionStatus { initial, loading, loaded, error }

class TransactionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();

  TransactionStatus _status = TransactionStatus.initial;
  List<Transaction> _transactions = [];
  String? _errorMessage;
  String? _userId;

  TransactionStatus get status => _status;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  String? get errorMessage => _errorMessage;

  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses => _transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpenses;

  void setUserId(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _listenToTransactions();
  }

  void _listenToTransactions() {
    if (_userId == null) return;
    _status = TransactionStatus.loading;
    notifyListeners();

    _firestoreService.watchTransactions(_userId!).listen(
      (transactions) {
        _transactions = transactions;
        _status = TransactionStatus.loaded;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Erro ao carregar transações';
        _status = TransactionStatus.error;
        notifyListeners();
      },
    );
  }

  Future<bool> addTransaction({
    required String description,
    required double amount,
    required TransactionType type,
    required TransactionCategory category,
    required DateTime date,
    File? receiptFile,
    String? notes,
  }) async {
    if (_userId == null) return false;

    try {
      String? receiptUrl;
      if (receiptFile != null) {
        receiptUrl = await _storageService.uploadReceipt(
          userId: _userId!,
          file: receiptFile,
        );
      }

      final transaction = Transaction(
        id: _uuid.v4(),
        userId: _userId!,
        description: description,
        amount: amount,
        type: type,
        category: category,
        date: date,
        receiptUrl: receiptUrl,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createTransaction(transaction);
      return true;
    } catch (_) {
      _errorMessage = 'Erro ao criar transação';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(
    Transaction transaction, {
    File? newReceiptFile,
  }) async {
    try {
      String? receiptUrl = transaction.receiptUrl;

      if (newReceiptFile != null) {
        if (receiptUrl != null) {
          await _storageService.deleteReceipt(receiptUrl);
        }
        receiptUrl = await _storageService.uploadReceipt(
          userId: _userId!,
          file: newReceiptFile,
        );
      }

      await _firestoreService.updateTransaction(
        transaction.copyWith(receiptUrl: receiptUrl),
      );
      return true;
    } catch (_) {
      _errorMessage = 'Erro ao atualizar transação';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(Transaction transaction) async {
    try {
      if (transaction.receiptUrl != null) {
        await _storageService.deleteReceipt(transaction.receiptUrl!);
      }
      await _firestoreService.deleteTransaction(transaction.id);
      return true;
    } catch (_) {
      _errorMessage = 'Erro ao excluir transação';
      notifyListeners();
      return false;
    }
  }

  List<Transaction> filterTransactions({
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? query,
  }) {
    return _transactions.where((t) {
      if (type != null && t.type != type) return false;
      if (startDate != null && t.date.isBefore(startDate)) return false;
      if (endDate != null && t.date.isAfter(endDate)) return false;
      if (query != null && query.isNotEmpty) {
        final lower = query.toLowerCase();
        if (!t.description.toLowerCase().contains(lower)) return false;
      }
      return true;
    }).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clear() {
    _transactions = [];
    _userId = null;
    _status = TransactionStatus.initial;
    notifyListeners();
  }
}
