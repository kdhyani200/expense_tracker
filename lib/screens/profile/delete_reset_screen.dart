import 'package:expense_tracker/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transactions_providers.dart';
import '../../providers/wallet_providers.dart';
import '../../providers/category_provider.dart';
import '../../services/data_services.dart';
import '../../snackbar_util.dart';

class DeleteResetScreen extends ConsumerWidget {
  const DeleteResetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: BackButton(color: Theme.of(context).primaryColor),
        title: Text(
          'Delete & Reset',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          _buildWarningBanner(),
          const SizedBox(height: 24),

          _ActionTile(
            icon: Icons.receipt_long_outlined,
            iconColor: Colors.orange,
            title: 'Delete All Records',
            description:
                'Removes all transactions but keeps your wallets and categories intact. Wallet balances will be reset to zero.',
            buttonLabel: 'Delete Records',
            buttonColor: Colors.orange,
            onTap: () => _confirm(
              context: context,
              ref: ref,
              title: 'Delete All Records?',
              body:
                  'This will permanently delete all transactions and reset wallet balances to ₹0. Wallets and categories will remain.',
              action: () async {
                await DataService.deleteAllRecords();
                ref.read(transactionsProvider.notifier).loadTransactions();
                ref.read(walletsProvider.notifier).loadWallets();
              },
              successMessage: 'All records deleted.',
            ),
          ),

          const SizedBox(height: 16),

          _ActionTile(
            icon: Icons.delete_sweep_outlined,
            iconColor: Colors.red,
            title: 'Delete All',
            description:
                'Removes every transaction, wallet, and category. Your profile is kept.',
            buttonLabel: 'Delete Everything',
            buttonColor: Colors.red,
            onTap: () => _confirm(
              context: context,
              ref: ref,
              title: 'Delete Everything?',
              body:
                  'This permanently deletes all transactions, wallets, and categories. Your profile info is not affected.',
              action: () async {
                await DataService.deleteEverything();
                ref.read(transactionsProvider.notifier).loadTransactions();
                ref.read(walletsProvider.notifier).loadWallets();
                ref.read(categoryProvider.notifier).loadCategories();
              },
              successMessage: 'Everything deleted.',
            ),
          ),

          const SizedBox(height: 16),

          _ActionTile(
            icon: Icons.restore_outlined,
            iconColor: Colors.deepPurple,
            title: 'Reset App',
            description:
                'Returns the app to its initial state. Deletes everything including your profile. You will be taken back to the onboarding screen.',
            buttonLabel: 'Reset App',
            buttonColor: Colors.deepPurple,
            onTap: () => _confirm(
              context: context,
              ref: ref,
              title: 'Reset App?',
              body:
                  'This will delete everything — records, wallets, categories, and your profile. The app will restart to the initial setup.',
              action: () async {
                await DataService.resetApp();
              },
              successMessage: 'App reset.',
              navigateToOnboarding: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade400,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'These actions are irreversible. Consider creating a backup first.',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String body,
    required Future<void> Function() action,
    required String successMessage,
    bool navigateToOnboarding = false,
  }) async {
    // First confirmation
    final first = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (first != true || !context.mounted) return;

    // Second confirmation — type "DELETE"
    final controller = TextEditingController();
    final second = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Are you absolutely sure?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Type DELETE to confirm:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  filled: true,
                  fillColor: Theme.of(context).canvasColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: controller.text == 'DELETE'
                  ? () => Navigator.pop(ctx, true)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
    if (second != true || !context.mounted) return;

    await action();

    if (!context.mounted) return;

    if (navigateToOnboarding) {
      // Swapped from pushNamedAndRemoveUntil to direct pushAndRemoveUntil route replacement
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnBoarding()),
        (route) => false, // Clears navigation stack history completely
      );
    } else {
      Navigator.pop(context);
      SnackBarUtils.showSnackBar(context, successMessage);
    }
  }
}

// ── Reusable action tile ───────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
