import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionsNotifier extends Notifier<List<TransactionModel>> {
  final TransactionService _transactionService = TransactionService();

  @override
  List<TransactionModel> build() {
    return _transactionService.getTransactions();
  }

  void loadTransactions() {
    state = _transactionService.getTransactions();
  }

  /// Computes total income from the current state list.
  /// NOTE: Consumers should watch [transactionsProvider] (the state list) and
  /// compute these values themselves for reactivity, rather than calling
  /// getters on the notifier (which does not register a dependency).
  double get totalIncome => _sumByType(TransactionType.income, state);

  double get totalExpenses => _sumByType(TransactionType.expense, state);

  double _sumByType(TransactionType type, List<TransactionModel> list) {
    return list
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionService.addTransaction(transaction);
    loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionService.updateTransaction(transaction);
    loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionService.deleteTransaction(id);
    // Optimistic local state update (avoids a full reload)
    state = state.where((tx) => tx.id != id).toList();
  }
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, List<TransactionModel>>(
      TransactionsNotifier.new,
    );
