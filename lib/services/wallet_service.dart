import '../models/wallet_model.dart';
import 'hive_service.dart';

class WalletService {
  Future<void> addWallet(WalletModel wallet) async {
    await HiveService.walletBox.put(wallet.id, wallet);
  }

  List<WalletModel> getWallets() {
    return HiveService.walletBox.values.toList();
  }

  Future<void> deleteWallet(String id) async {
    await HiveService.walletBox.delete(id);
  }

  /// BUG FIX: Previously called wallet.save() on a freshly constructed
  /// WalletModel that was never loaded from Hive, so save() silently did
  /// nothing.  Using box.put() with the wallet's own id correctly overwrites
  /// the stored record regardless of how the object was created.
  Future<void> updateWallet(WalletModel wallet) async {
    await HiveService.walletBox.put(wallet.id, wallet);
  }
}
