import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';
import '../providers/preferences_provider.dart';
import '../providers/transactions_providers.dart';
import '../providers/wallet_providers.dart';
import '../utils/amount_formatter.dart';

class MainCard extends ConsumerWidget {
  const MainCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final allWallets = ref.watch(walletsProvider);
    final prefs = ref.watch(preferencesProvider);

    final double income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final double expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    final double total = allWallets.fold(0.0, (s, w) => s + w.balance);

    final sym = prefs.currencySymbol;
    final dec = prefs.decimalPlaces;

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.28,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00787a), Color(0xFF10b981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TOTAL BALANCE',
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatAmount(total, sym, dec),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Divider(thickness: 2, color: Colors.white.withValues(alpha: 0.1)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _detail(
                Icons.arrow_downward,
                'Income',
                formatAmount(income, sym, dec),
              ),
              _detail(
                Icons.arrow_upward,
                'Expense',
                formatAmount(expense, sym, dec),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detail(IconData icon, String label, String amount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
