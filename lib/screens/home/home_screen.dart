import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/transactions_providers.dart';
import '../../providers/user_profile.dart';
import '../../widget/main_card.dart';
import '../../widget/transactions_card.dart';
import '../add/add_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _showFab = true;

  void _openAddTransactionScreen() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => const AddScreen(),
    );
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showFab) {
          setState(() {
            _showFab = false;
          });
        }
      }

      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showFab) {
          setState(() {
            _showFab = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _buildUserHeader(),
        actions: [_buildSearchIcon()],
      ),

      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: _showFab ? Offset.zero : const Offset(0, 2),

        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _showFab ? 1 : 0,

          child: FloatingActionButton(
            backgroundColor: const Color(0xFF00885d),

            onPressed: _openAddTransactionScreen,

            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),

      body: SingleChildScrollView(
        controller: _scrollController,

        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const MainCard(),

            const SizedBox(height: 24),

            const Text(
              "Recent Transactions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            transactions.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) =>
                        TransactionItemCard(transaction: transactions[index]),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),

            const SizedBox(height: 16),

            Text(
              "No transactions yet",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),

            Text(
              "Add your first expense or income to see it here.",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    final user = ref.watch(userProfileProvider);

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,

          children: [
            Text(
              "Hello,",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),

            Text(
              (user == null ||
                      (user.firstName.trim().isEmpty &&
                          user.lastName.trim().isEmpty))
                  ? "User"
                  : "${user.firstName} ${user.lastName}".trim(),

              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),

      child: CircleAvatar(
        backgroundColor: Colors.grey[100],

        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
          icon: const Icon(Icons.search, color: Colors.black87),
        ),
      ),
    );
  }
}
