import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../providers/transactions_providers.dart';
import '../providers/wallet_providers.dart';

class MainCard extends ConsumerWidget {
  const MainCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // BUG FIX: watch transactionsProvider (the state list) instead of accessing
    // .notifier getters directly.  Accessing getters on the notifier doesn't
    // register a dependency, so the card would not rebuild when transactions
    // changed.  By watching the state list and computing totals from it the
    // widget correctly rebuilds on every change.
    final transactions = ref.watch(transactionsProvider);
    final allWallets = ref.watch(walletsProvider);

    final double overallIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final double overExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final double total = allWallets.fold(0.0, (sum, w) => sum + w.balance);

    // BUG FIX: format amounts with commas and 2 decimal places instead of
    // showing raw double (e.g. "1000.0" → "1,000.00").
    final fmt = NumberFormat('#,##0.00', 'en_IN');

    final media = MediaQuery.of(context);

    return Container(
      width: double.infinity,
      height: media.size.height * 0.28,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF10b981),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10b981).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "TOTAL BALANCE",
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₹${fmt.format(total)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Divider(thickness: 2, color: Colors.white.withValues(alpha: 0.1)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceDetail(
                icon: Icons.arrow_downward,
                label: "Income",
                amount: "₹${fmt.format(overallIncome)}",
              ),
              _buildBalanceDetail(
                icon: Icons.arrow_upward,
                label: "Expense",
                amount: "₹${fmt.format(overExpense)}",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail({
    required IconData icon,
    required String label,
    required String amount,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
