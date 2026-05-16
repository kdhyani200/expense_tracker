import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transactions_providers.dart';
import '../../providers/user_profile.dart';
import '../../widget/main_card.dart';
import '../../widget/transactions_card.dart';
import '../add/add_screen.dart';
import '../categories_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  bool _showFab = true;
  bool _fabOpen = false;
  late AnimationController _animCtrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showFab) {
          _closeFab();
          setState(() => _showFab = false);
        }
      }

      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showFab) {
          setState(() => _showFab = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() => _fabOpen = !_fabOpen);
    _fabOpen ? _animCtrl.forward() : _animCtrl.reverse();
  }

  void _closeFab() {
    if (_fabOpen) {
      setState(() => _fabOpen = false);
      _animCtrl.reverse();
    }
  }

  void _openAddTransaction() {
    _closeFab();
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (_) => const AddScreen(),
    );
  }

  void _openCategories() {
    _closeFab();
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (_) => const CategoriesScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    return GestureDetector(
      onTap: _closeFab,
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: _buildUserHeader(),
          actions: [_buildSearchIcon()],
        ),

        // ── Animated FAB with two options ──────────────────────────────
        floatingActionButton: AnimatedSlide(
          duration: const Duration(milliseconds: 250),
          offset: _showFab ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: _showFab ? 1 : 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ── Option pills (animate in/out) ────────────────────
                ScaleTransition(
                  scale: _expandAnim,
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _FabOption(
                        icon: Icons.category_rounded,
                        label: "Categories",
                        color: const Color(0xFF7C4DFF),
                        onTap: _openCategories,
                      ),
                      const SizedBox(height: 10),
                      _FabOption(
                        icon: Icons.add_card_rounded,
                        label: "Transaction",
                        color: const Color(0xFF00885d),
                        onTap: _openAddTransaction,
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),

                // ── Main FAB ─────────────────────────────────────────
                AnimatedRotation(
                  turns: _fabOpen ? 0.125 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: FloatingActionButton(
                    backgroundColor: const Color(0xFF00885d),
                    onPressed: _toggleFab,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),

        body: GestureDetector(
          onTap: _closeFab,
          child: SingleChildScrollView(
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
                        itemBuilder: (context, index) => TransactionItemCard(
                          transaction: transactions[index],
                        ),
                      ),
              ],
            ),
          ),
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

// ── FAB option pill ───────────────────────────────────────────────────────────

class _FabOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FabOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
