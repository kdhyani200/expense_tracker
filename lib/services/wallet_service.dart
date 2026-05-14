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

  Future<void> updateWallet(WalletModel wallet) async {
    await wallet.save();
  }
}
