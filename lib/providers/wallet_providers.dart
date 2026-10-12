import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../services/wallet_service.dart';
import '../services/hive_service.dart';

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
  /// BUG FIX: Previously called wallet.save() on the in-memory state object
  /// which may not be a managed Hive object (e.g. after loadWallets() rebuilds
  /// state from box.values, the objects ARE managed — but to be safe and
  /// explicit we always use box.put() directly.
  Future<void> updateWalletBalance({
    required String walletId,
    required double amount,
    required TransactionType type,
  }) async {
    final walletIndex = state.indexWhere((w) => w.id == walletId);

    if (walletIndex == -1) {
      debugPrint("updateWalletBalance: wallet '$walletId' not found");
      return;
    }

    final wallet = state[walletIndex];

    final updatedBalance = type == TransactionType.income
        ? wallet.balance + amount
        : wallet.balance - amount;

    // BUG FIX: Use box.put() instead of wallet.save() to guarantee persistence
    // regardless of whether the in-memory object is a managed Hive object.
    await HiveService.walletBox.put(
      walletId,
      WalletModel(
        id: wallet.id,
        name: wallet.name,
        balance: updatedBalance,
        imagePath: wallet.imagePath,
        createdAt: wallet.createdAt,
      ),
    );

    // Reload from Hive so state always reflects what's persisted
    loadWallets();
  }

  List<String> getWalletNames() {
    return state.map((wallet) => wallet.name).toList();
  }
}

final walletsProvider = NotifierProvider<WalletsNotifier, List<WalletModel>>(
  WalletsNotifier.new,
);
