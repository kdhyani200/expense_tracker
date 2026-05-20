import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../providers/category_provider.dart';
import '../utils/category_styles.dart';
import '../screens/add/add_screen.dart';

class TransactionItemCard extends ConsumerWidget {
  final TransactionModel transaction;
  const TransactionItemCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customCats = ref.watch(categoryProvider);
    final isIncome = transaction.type == TransactionType.income;
    final style = styleForTransaction(transaction, customCats);
    final fmt = NumberFormat('#,##0.00', 'en_IN');

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => AddScreen(existing: transaction),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Icon / image badge ──────────────────────────────────
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: _buildBadge(style),
            ),

            const SizedBox(width: 16),

            // ── Category + note ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (transaction.note.isNotEmpty)
                    Text(
                      transaction.note,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // ── Amount + date + chevron ─────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${isIncome ? '+' : '-'} ₹${fmt.format(transaction.amount)}",
                      style: TextStyle(
                        color: isIncome
                            ? const Color(0xFF00885d)
                            : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(transaction.date),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Renders either a gallery image or an icon inside the badge.
  Widget _buildBadge(CategoryStyle style) {
    final path = style.imagePath;
    if (path != null && File(path).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.file(File(path), fit: BoxFit.cover),
      );
    }
    return Icon(style.icon, color: style.color, size: 24);
  }

  /// Formats the date to show both date and time (e.g., "19 May 2026 4:28 PM")
  String _formatDate(DateTime d) {
    return DateFormat('d MMM yyyy h:mm a').format(d);
  }
}
