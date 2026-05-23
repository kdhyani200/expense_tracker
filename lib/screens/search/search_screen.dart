import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_model.dart';
import '../../utils/category_styles.dart';
import '../../providers/transactions_providers.dart';
import '../add/add_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<TransactionModel> _filter(List<TransactionModel> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((tx) {
      return tx.category.toLowerCase().contains(q) ||
          tx.note.toLowerCase().contains(q) ||
          tx.amount.toStringAsFixed(0).contains(q) ||
          (tx.type == TransactionType.income ? 'income' : 'expense').contains(
            q,
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(transactionsProvider);
    final filtered = _filter(all);
    final fmt = NumberFormat('#,##0.00', 'en_IN');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          "Search",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ──────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                style: TextStyle(color: Theme.of(context).primaryColor),
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: "Search by category, note or amount…",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 20,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 18,
                          ),
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Result count ────────────────────────────────────────────
            if (_query.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 2),
                child: Text(
                  "${filtered.length} result${filtered.length == 1 ? '' : 's'}",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),

            // ── List ────────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) =>
                          _buildCard(context, filtered[i], fmt),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    TransactionModel tx,
    NumberFormat fmt,
  ) {
    final isIncome = tx.type == TransactionType.income;
    final style = styleForTransaction(tx);

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => AddScreen(existing: tx),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: style.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(style.icon, color: style.color, size: 22),
            ),

            const SizedBox(width: 14),

            // Category + note with matched text highlighted
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _highlight(
                    tx.category,
                    _query,
                    TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (tx.note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    _highlight(
                      tx.note,
                      _query,
                      TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),

            // Amount + date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isIncome ? '+' : '-'} ₹${fmt.format(tx.amount)}",
                  style: TextStyle(
                    color: isIncome
                        ? const Color(0xFF66BB6A)
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('d MMM yyyy').format(tx.date),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isEmpty = _query.isEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEmpty ? Icons.search : Icons.search_off,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            isEmpty ? "Start typing to search" : "No results for \"$_query\"",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
          if (!isEmpty) ...[
            const SizedBox(height: 4),
            Text(
              "Try a different keyword",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  /// Highlights every occurrence of [query] inside [text] in green.
  Widget _highlight(
    String text,
    String query,
    TextStyle base, {
    int maxLines = 2,
  }) {
    if (query.isEmpty) {
      return Text(
        text,
        style: base,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lower.indexOf(q, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + q.length),
          style: const TextStyle(
            color: Color(0xFF10b981),
            fontWeight: FontWeight.bold,
            backgroundColor: Color(0x1A10b981),
          ),
        ),
      );
      start = idx + q.length;
    }

    return RichText(
      text: TextSpan(style: base, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
