import 'package:expense_tracker/screens/wallet/add_wallet.dart';
import 'package:expense_tracker/screens/wallet/update_wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/wallet.dart';
import '../../providers/wallet_providers.dart';
import '../../widget/wallet_card.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  void _openUpdateWallet(BuildContext context, Wallet wallet, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpdateWalletScreen(
        wallet: wallet,
        onDelete: () => ref.read(walletsProvider.notifier).deleteWallet(index),
        onUpdate: (name, image) =>
            ref.read(walletsProvider.notifier).updateWallet(index, name, image),
      ),
    );
  }

  void _openAddWallet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddWalletScreen(
        onAdd: (name, image) =>
            ref.read(walletsProvider.notifier).addWallet(name, image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allWallets = ref.watch(walletsProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    double total = allWallets.fold(
      0,
      (sum, item) => sum + double.parse(item.amount),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.08),
            // Dynamic Total Balance Section
            Center(
              child: Column(
                children: [
                  Text(
                    "₹${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Total balance",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.075),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "My Wallets",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openAddWallet(),
                          icon: const Icon(
                            Icons.add_circle,
                            color: Color(0xFF00885d),
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: allWallets.length,
                        itemBuilder: (context, index) {
                          final wallet = allWallets[index];
                          return WalletCard(
                            wallet: wallet,
                            onTap: () =>
                                _openUpdateWallet(context, wallet, index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
