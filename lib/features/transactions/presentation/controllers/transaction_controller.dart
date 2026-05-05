import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/watch_transactions.dart';

/// Estados possíveis da listagem de transações.
enum TransactionStatus {
  /// Estado inicial, antes de qualquer carregamento.
  initial,

  /// Carregando dados do repositório.
  loading,

  /// Dados disponíveis em [TransactionController.transactions].
  loaded,

  /// Última operação falhou. A `errorMessage` está populada.
  error,
}

/// Controller (camada de apresentação) que mantém a lista de transações
/// em memória e orquestra os casos de uso de criação, atualização e
/// exclusão.
///
/// Mantém o contrato consumido pelas telas existentes: estado observável
/// via [ChangeNotifier] e métodos que retornam `bool` indicando sucesso.
class TransactionController extends ChangeNotifier {
  final WatchTransactions _watchTransactions;
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final Uuid _uuid;

  StreamSubscription<List<TransactionEntity>>? _subscription;
  TransactionStatus _status = TransactionStatus.initial;
  List<TransactionEntity> _transactions = const [];
  String? _errorMessage;
  String? _userId;

  /// Cria um [TransactionController] ligado aos casos de uso.
  TransactionController({
    required WatchTransactions watchTransactions,
    required CreateTransaction createTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
    Uuid? uuid,
  })  : _watchTransactions = watchTransactions,
        _createTransaction = createTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        _uuid = uuid ?? const Uuid();

  /// Estado atual da listagem.
  TransactionStatus get status => _status;

  /// Lista imutável das transações carregadas.
  List<TransactionEntity> get transactions =>
      List.unmodifiable(_transactions);

  /// Última mensagem de erro localizada, quando aplicável.
  String? get errorMessage => _errorMessage;

  /// Soma de todas as transações do tipo [TransactionType.income].
  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Soma de todas as transações do tipo [TransactionType.expense].
  double get totalExpenses => _transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Saldo (receitas - despesas), preservando a regra de negócio
  /// existente.
  double get balance => totalIncome - totalExpenses;

  /// Define o usuário atualmente autenticado e, se diferente do anterior,
  /// reinicia a assinatura do stream de transações.
  void setUserId(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _listen();
  }

  /// Inicia (ou reinicia) a assinatura ao stream de transações para
  /// [_userId].
  void _listen() {
    if (_userId == null) return;
    _subscription?.cancel();
    _status = TransactionStatus.loading;
    notifyListeners();

    _subscription = _watchTransactions(_userId!).listen(
      (list) {
        _transactions = list;
        _status = TransactionStatus.loaded;
        notifyListeners();
      },
      onError: (_) {
        _errorMessage = 'Erro ao carregar transações';
        _status = TransactionStatus.error;
        notifyListeners();
      },
    );
  }

  /// Cria uma nova transação a partir dos campos informados, anexando
  /// um comprovante quando [receiptFile] estiver presente. Retorna
  /// `true` quando a operação concluir com sucesso.
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

    final draft = TransactionEntity(
      id: _uuid.v4(),
      userId: _userId!,
      description: description,
      amount: amount,
      type: type,
      category: category,
      date: date,
      receiptUrl: null,
      notes: notes,
      createdAt: DateTime.now(),
    );

    final result = await _createTransaction(
      transaction: draft,
      receiptFile: receiptFile,
    );
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) => true,
    );
  }

  /// Atualiza uma transação existente. Quando [newReceiptFile] está
  /// presente, o comprovante anterior é substituído pelo novo.
  Future<bool> updateTransactionEntry(
    TransactionEntity transaction, {
    File? newReceiptFile,
  }) async {
    final result = await _updateTransaction(
      transaction: transaction,
      newReceiptFile: newReceiptFile,
    );
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) => true,
    );
  }

  /// Remove [transaction] e o respectivo comprovante, se houver.
  Future<bool> deleteTransactionEntry(TransactionEntity transaction) async {
    final result = await _deleteTransaction(transaction);
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) => true,
    );
  }

  /// Filtra as transações em memória por tipo, intervalo de data e
  /// trecho da descrição. Mantém o algoritmo idêntico ao da
  /// implementação anterior para preservar o comportamento da tela de
  /// listagem.
  List<TransactionEntity> filterTransactions({
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
    }).toList(growable: false);
  }

  /// Limpa a mensagem de erro atual.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reseta o estado interno (usado no logout).
  void clear() {
    _subscription?.cancel();
    _subscription = null;
    _transactions = const [];
    _userId = null;
    _status = TransactionStatus.initial;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
