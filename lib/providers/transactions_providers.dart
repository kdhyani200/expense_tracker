import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_item.dart';

class TransactionsNotifier extends Notifier<List<Transaction>> {
  @override
  List<Transaction> build() {
    return [
      // Transaction(
      //   type: Type.Expense,
      //   wallet: 'Cash',
      //   category: ExpenseCategory.food,
      //   date: DateTime.now().subtract(const Duration(days: 1)),
      //   amount: '150',
      //   description: 'Lunch with friends',
      // ),
      // Transaction(
      //   type: Type.Income,
      //   wallet: 'Bank Account',
      //   category: ExpenseCategory.other,
      //   date: DateTime.now(),
      //   amount: '5000',
      //   description: 'Monthly Salary',
      // ),
      // Transaction(
      //   type: Type.Expense,
      //   wallet: 'Credit Card',
      //   category: ExpenseCategory.shopping,
      //   date: DateTime.now(),
      //   amount: '1200',
      //   description: 'New Sneakers',
      // ),
    ];
  }

  double get totalIncome => _sumByType(Type.Income, state);
  double get totalExpenses => _sumByType(Type.Expense, state);

  double _sumByType(Type type, List<Transaction> list) {
    return list
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + double.parse(t.amount));
  }

  void addTransaction(Transaction transaction) {
    state = [transaction, ...state];
  }

  void deleteTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  // // Update a transaction
  // void updateTransaction(Transaction updatedTransaction) {
  //   state = [
  //     for (final t in state)
  //       if (t.id == updatedTransaction.id) updatedTransaction else t,
  //   ];
  // }
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, List<Transaction>>(() {
      return TransactionsNotifier();
    });
