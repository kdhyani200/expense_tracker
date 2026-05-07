import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet.dart';

class WalletsNotifier extends Notifier<List<Wallet>> {
  @override
  List<Wallet> build() {
    return [
      Wallet(name: 'Cash', amount: '1000', image: null),
      Wallet(name: 'Credit Card', amount: '1050', image: null),
      Wallet(name: 'Bank Account', amount: '2800', image: null),
      Wallet(name: 'PayPal', amount: '500', image: null),
    ];
  }

  void addWallet(String name, File? image) {
    final newWallet = Wallet(name: name, amount: '0.00', image: image);
    state = [...state, newWallet];
  }

  void updateWallet(int index, String name, File? image) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          Wallet(name: name, amount: state[i].amount, image: image)
        else
          state[i],
    ];
  }

  void deleteWallet(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }

  List<String> getWalletNames() {
    return state.map((wallet) => wallet.name).toList();
  }
}

final walletsProvider = NotifierProvider<WalletsNotifier, List<Wallet>>(() {
  return WalletsNotifier();
});
