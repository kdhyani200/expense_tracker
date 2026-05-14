import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../screens/add/add_screen.dart';

// ── Category metadata ─────────────────────────────────────────────────────────

class _CategoryStyle {
  final IconData icon;
  final Color color;
  const _CategoryStyle(this.icon, this.color);
}

const Map<String, _CategoryStyle> _categoryStyles = {
  'food': _CategoryStyle(Icons.restaurant, Color(0xFF4CAF50)),
  'travel': _CategoryStyle(Icons.flight_takeoff, Color(0xFF2196F3)),
  'transport': _CategoryStyle(Icons.directions_bus, Color(0xFF2196F3)),
  'shopping': _CategoryStyle(Icons.shopping_bag, Color(0xFFFF9800)),
  'bills': _CategoryStyle(Icons.receipt_long, Color(0xFF9C27B0)),
  'entertainment': _CategoryStyle(Icons.movie, Color(0xFFE91E63)),
  'health': _CategoryStyle(Icons.medical_services, Color(0xFFF44336)),
  'clothing': _CategoryStyle(Icons.checkroom, Color(0xFF00BCD4)),
  'education': _CategoryStyle(Icons.school, Color(0xFF3F51B5)),
  'other': _CategoryStyle(Icons.miscellaneous_services, Color(0xFF607D8B)),
};

const _fallbackExpense = _CategoryStyle(Icons.payments, Color(0xFF607D8B));
const _incomeStyle = _CategoryStyle(Icons.monetization_on, Color(0xFF00885d));

_CategoryStyle _styleFor(TransactionModel tx) {
  if (tx.type == TransactionType.income) return _incomeStyle;
  return _categoryStyles[tx.category.toLowerCase()] ?? _fallbackExpense;
}

// ── Card ──────────────────────────────────────────────────────────────────────

class TransactionItemCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionItemCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final style = _styleFor(transaction);
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Icon badge ──────────────────────────────────────────────
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(style.icon, color: style.color, size: 24),
            ),

            const SizedBox(width: 16),

            // ── Category + note ─────────────────────────────────────────
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

            // ── Amount + date + chevron ─────────────────────────────────
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
                    Text(
                      DateFormat('d MMM').format(transaction.date),
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
}
