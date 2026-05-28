import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/wallet_model.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/wallet_providers.dart';
import '../../utils/amount_formatter.dart';
import '../../widget/wallet_card.dart';
import 'add_edit_wallet_screen.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  void _openSheet(BuildContext context, {WalletModel? wallet}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditWalletScreen(wallet: wallet),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allWallets = ref.watch(walletsProvider);
    final prefs = ref.watch(preferencesProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final fmt = NumberFormat('#,##0.00', 'en_IN');

    final double total = allWallets.fold(0.0, (sum, w) => sum + w.balance);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.08),

            // ── Total balance header ──────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    formatAmount(
                      total,
                      prefs.currencySymbol,
                      prefs.decimalPlaces,
                    ),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
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

            // ── Wallet list ───────────────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
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
                        Text(
                          "My Wallets",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openSheet(context),
                          icon: const Icon(
                            Icons.add,
                            color: Color(0xFF00885d),
                            size: 30,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: allWallets.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: allWallets.length,
                              itemBuilder: (context, index) {
                                final wallet = allWallets[index];
                                return WalletCard(
                                  wallet: wallet,
                                  onTap: () =>
                                      _openSheet(context, wallet: wallet),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              "No wallets yet",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade300,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "Tap + to add your first wallet.",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade300),
            ),
          ],
        ),
      ),
    );
  }
}
