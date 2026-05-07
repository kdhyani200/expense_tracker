import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/transactions_providers.dart';
import '../providers/wallet_providers.dart';

class MainCard extends ConsumerStatefulWidget {
  const MainCard({super.key});

  @override
  ConsumerState<MainCard> createState() => _MainCardState();
}

class _MainCardState extends ConsumerState<MainCard> {
  @override
  Widget build(BuildContext context) {
    final transactionLogic = ref.watch(transactionsProvider.notifier);
    final overallIncome = transactionLogic.totalIncome;
    final overExpense = transactionLogic.totalExpenses;
    final allWallets = ref.watch(walletsProvider);
    double total = allWallets.fold(
      0,
      (sum, item) => sum + double.parse(item.amount),
    );

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
            "₹${total}",
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
                amount: "₹$overallIncome",
              ),
              _buildBalanceDetail(
                icon: Icons.arrow_upward,
                label: "Expense",
                amount: "₹$overExpense",
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
