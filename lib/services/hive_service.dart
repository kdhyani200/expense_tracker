import 'package:hive/hive.dart';

import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';

class HiveService {
  static Box<UserModel> get userBox => Hive.box<UserModel>('user');

  static Box<WalletModel> get walletBox => Hive.box<WalletModel>('wallets');

  static Box<TransactionModel> get transactionBox =>
      Hive.box<TransactionModel>('transactions');
}
