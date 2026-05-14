import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wallet_model.dart';
import '../services/wallet_service.dart';
import '../models/transaction_model.dart';

class WalletsNotifier extends Notifier<List<WalletModel>> {
  final WalletService _walletService = WalletService();

  @override
  List<WalletModel> build() {
    return _walletService.getWallets();
  }

  void loadWallets() {
    state = _walletService.getWallets();
  }

  Future<bool> addWallet(WalletModel wallet) async {
    final alreadyExists = state.any(
      (w) => w.name.trim().toLowerCase() == wallet.name.trim().toLowerCase(),
    );

    if (alreadyExists) return false;

    await _walletService.addWallet(wallet);
    loadWallets();
    return true;
  }

  Future<void> updateWallet(WalletModel wallet) async {
    await _walletService.updateWallet(wallet);
    loadWallets();
  }

  Future<void> deleteWallet(String id) async {
    await _walletService.deleteWallet(id);
    loadWallets();
  }

  /// Updates the wallet balance in Hive and refreshes provider state.
  ///
  /// This is the SINGLE authoritative place that mutates wallet balance.
  /// [TransactionService.addTransaction] must NOT also change balance, or
  /// every transaction would be applied twice (the original doubling bug).
  Future<void> updateWalletBalance({
    required String walletId,
    required double amount,
    required TransactionType type,
  }) async {
    final walletIndex = state.indexWhere((wallet) => wallet.id == walletId);

    if (walletIndex == -1) {
      debugPrint("updateWalletBalance: wallet '$walletId' not found");
      return;
    }

    final wallet = state[walletIndex];

    final updatedBalance = type == TransactionType.income
        ? wallet.balance + amount
        : wallet.balance - amount;

    wallet.balance = updatedBalance;

    // Persist to Hive
    await wallet.save();

    // Trigger UI rebuild with a new list reference
    state = [...state];
  }

  List<String> getWalletNames() {
    return state.map((wallet) => wallet.name).toList();
  }
}

final walletsProvider = NotifierProvider<WalletsNotifier, List<WalletModel>>(
  WalletsNotifier.new,
);
