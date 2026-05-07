import 'package:expense_tracker/models/transaction_item.dart';
import 'package:expense_tracker/providers/transactions_providers.dart';
import 'package:expense_tracker/providers/wallet_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../snackbar_util.dart';

class TransactionItemCard extends ConsumerStatefulWidget {
  final Transaction transaction;

  const TransactionItemCard({super.key, required this.transaction});

  @override
  ConsumerState<TransactionItemCard> createState() =>
      _TransactionItemCardState();
}

class _TransactionItemCardState extends ConsumerState<TransactionItemCard> {
  @override
  Widget build(BuildContext context) {
    final bool isIncome = widget.transaction.type == Type.Income;
    final Color categoryColor = widget.transaction.category.color;
    final IconData categoryIcon = widget.transaction.category.icon;

    return Dismissible(
      key: Key(widget.transaction.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        final reverseType = isIncome ? Type.Expense : Type.Income;

        ref
            .read(walletsProvider.notifier)
            .updateWalletBalance(
              widget.transaction.wallet,
              widget.transaction.amount,
              reverseType,
            );

        ref
            .read(transactionsProvider.notifier)
            .deleteTransaction(widget.transaction.id);

        SnackBarUtils.showSnackBar(
          context,
          "Transaction deleted and balance adjusted",
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isIncome
                    ? const Color(0xFF00885d).withOpacity(0.1)
                    : categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: isIncome
                  ? const Icon(
                      Icons.monetization_on,
                      color: Color(0xFF00885d),
                      size: 26,
                    )
                  : Icon(categoryIcon, color: categoryColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isIncome ? "Income" : widget.transaction.category.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.transaction.description != null)
                    Text(
                      widget.transaction.description!,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isIncome ? '+ ' : '- '}₹${widget.transaction.amount}",
                  style: TextStyle(
                    color: isIncome
                        ? const Color(0xFF00885d)
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat('d MMM').format(widget.transaction.date),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
