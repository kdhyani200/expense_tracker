import '../models/transaction_model.dart';
import 'hive_service.dart';

class TransactionService {
  /// Persists a transaction to Hive.
  ///
  /// NOTE: Wallet balance is intentionally NOT updated here.
  /// Balance updates are handled exclusively by WalletsNotifier so the
  /// balance is never applied twice.
  Future<void> addTransaction(TransactionModel tx) async {
    await HiveService.transactionBox.put(tx.id, tx);
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    await HiveService.transactionBox.put(tx.id, tx);
  }

  List<TransactionModel> getTransactions() {
    final transactions = HiveService.transactionBox.values.toList();
    // Sort newest first
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  List<TransactionModel> getWalletTransactions(String walletId) {
    final transactions = HiveService.transactionBox.values
        .where((e) => e.walletId == walletId)
        .toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  /// Deletes only the transaction record.
  /// Callers must reverse the wallet balance separately via WalletsNotifier.
  Future<void> deleteTransaction(String id) async {
    await HiveService.transactionBox.delete(id);
  }
}
