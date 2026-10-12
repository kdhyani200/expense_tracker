import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/transactions_providers.dart';
import '../../providers/user_profile.dart';
import '../../services/data_services.dart';
import '../../services/permission_service.dart';
import '../../utils/snackbar_util.dart';
import 'backup_restore_screen.dart';
import 'delete_reset_screen.dart';
import 'edit_profile_picture.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final prefs = ref.watch(preferencesProvider);
    final transactions = ref.watch(transactionsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.28;

    final File? photo = user?.imagePath != null ? File(user!.imagePath!) : null;
    final displayName =
        (user == null ||
            (user.firstName.trim().isEmpty && user.lastName.trim().isEmpty))
        ? 'User'
        : '${user.firstName} ${user.lastName}'.trim();

    const String _packageName = 'com.kd.expense_tracker'; // Replace with your actual package name


    Future<void> _rateApp(BuildContext context) async {
    final Uri marketUri = Uri.parse('market://details?id=$_packageName');
    final Uri webUri = Uri.parse('https://google.com');

    try {
      // Close the drawer first
      Navigator.pop(context);

      // Attempt to launch the deep link directly to the native Google Play Store app
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to opening the browser layout if the store app isn't present
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle potential routing errors gracefully
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the store link.')),
        );
      }
    }
  }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Profile header card ───────────────────────────────────────
              Container(
                width: double.infinity,
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          context: context,
                          builder: (_) => AddProfilePictureScreen(
                            firstName: user?.firstName ?? '',
                            lastName: user?.lastName ?? '',
                            initialImage: photo,
                            onPickImage: (_) {},
                          ),
                        );
                        ref.read(userProfileProvider.notifier).loadUser();
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: imageSize,
                            height: imageSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).shadowColor,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: photo != null && photo.existsSync()
                                ? Image.file(photo, fit: BoxFit.cover)
                                : Icon(
                                    Icons.person,
                                    size: imageSize * 0.4,
                                    color: Colors.grey.shade400,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00885d),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transactions.length} transactions',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Preferences ───────────────────────────────────────────────
              _Section(
                title: 'Preferences',
                children: [
                  _SettingTile(
                    icon: Icons.brightness_6_outlined,
                    iconColor: Colors.indigo,
                    title: 'UI Mode',
                    subtitle: _themeName(prefs.themeMode),
                    onTap: () =>
                        _showThemePicker(context, ref, prefs.themeMode),
                  ),
                  _SettingTile(
                    icon: Icons.currency_exchange,
                    iconColor: Colors.teal,
                    title: 'Currency',
                    subtitle: '${prefs.currencyCode} (${prefs.currencySymbol})',
                    onTap: () => _showCurrencyPicker(context, ref),
                  ),
                  _SettingTile(
                    icon: Icons.pin_outlined,
                    iconColor: Colors.orange,
                    title: 'Decimal Places',
                    subtitle: prefs.decimalPlaces.toString(),
                    onTap: () =>
                        _showDecimalPicker(context, ref, prefs.decimalPlaces),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Data ──────────────────────────────────────────────────────
              _Section(
                title: 'Data',
                children: [
                  _SettingTile(
                    icon: Icons.upload_file_outlined,
                    iconColor: Colors.blue,
                    title: 'Export to CSV',
                    subtitle: 'Save all transactions as a spreadsheet',
                    onTap: () => _exportCsv(context),
                  ),
                  _SettingTile(
                    icon: Icons.cloud_done_outlined,
                    iconColor: const Color(0xFF00885d),
                    title: 'Backup & Restore',
                    subtitle: 'Save or restore your data (.mbak)',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BackupRestoreScreen(),
                      ),
                    ),
                  ),
                  _SettingTile(
                    icon: Icons.delete_outline_rounded,
                    iconColor: Colors.red,
                    title: 'Delete & Reset',
                    subtitle: 'Remove records, wallets or reset the app',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeleteResetScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── App info ──────────────────────────────────────────────────
              _Section(
                title: 'App',
                children: [
                  _SettingTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.blueGrey,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  _SettingTile(
                    icon: Icons.info_outline,
                    iconColor: Colors.grey,
                    title: 'Version',
                    subtitle: '1.0.7',
                    onTap: () {},
                    showChevron: false,
                  ),
                  _SettingTile(
                    icon: Icons.star_outline,
                    iconColor: Colors.grey,
                    title: 'Rate App / Support',
                    subtitle: 'Leave a review or contact us',
                    onTap: () => _rateApp(context),
                  )
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  String _themeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'UI Mode',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final mode in [
            ThemeMode.system,
            ThemeMode.light,
            ThemeMode.dark,
          ])
            ListTile(
              leading: Icon(
                mode == ThemeMode.system
                    ? Icons.brightness_auto
                    : mode == ThemeMode.light
                    ? Icons.wb_sunny_outlined
                    : Icons.nightlight_round,
                color: const Color(0xFF00885d),
              ),
              title: Text(_themeName(mode)),
              trailing: mode == current
                  ? const Icon(Icons.check_rounded, color: Color(0xFF00885d))
                  : null,
              onTap: () {
                ref.read(preferencesProvider.notifier).setThemeMode(mode);
                Navigator.pop(context);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    final prefs = ref.read(preferencesProvider);
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final query = controller.text.toLowerCase();
          final filtered = query.isEmpty
              ? kCurrencies
              : kCurrencies
                    .where(
                      (c) =>
                          c.name.toLowerCase().contains(query) ||
                          c.code.toLowerCase().contains(query),
                    )
                    .toList();

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (_, scroll) => Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select Currency',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: controller,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search currency…',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).canvasColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: scroll,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      final selected = c.code == prefs.currencyCode;
                      return ListTile(
                        leading: Text(
                          c.flag,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text('${c.name} (${c.code})'),
                        subtitle: Text(c.symbol),
                        trailing: selected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Color(0xFF00885d),
                              )
                            : null,
                        onTap: () {
                          ref
                              .read(preferencesProvider.notifier)
                              .setCurrency(c.symbol, c.code);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDecimalPicker(BuildContext context, WidgetRef ref, int current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Decimal Places',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final n in [0, 1, 2])
            ListTile(
              title: Text(
                n == 0
                    ? '0 — e.g. ₹1,000'
                    : n == 1
                    ? '1 — e.g. ₹1,000.0'
                    : '2 — e.g. ₹1,000.00',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              trailing: n == current
                  ? const Icon(Icons.check_rounded, color: Color(0xFF00885d))
                  : null,
              onTap: () {
                ref.read(preferencesProvider.notifier).setDecimalPlaces(n);
                Navigator.pop(context);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    final granted = await PermissionService.requestStoragePermission();

    if (!granted) return;
    // 1. Ask user where to save
    final selectedDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose where to save the CSV',
    );
    // User cancelled the picker
    if (selectedDir == null) return;
    if (!context.mounted) return;

    try {
      final path = await DataService.exportCsv();
      if (!context.mounted) return;

      // Open with system viewer / share sheet
      await DataService.openFile(path);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF00885d)),
              const SizedBox(width: 8),
              const Text(
                'CSV Exported',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('File saved to:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  path,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00885d),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showSnackBar(context, 'Export failed: $e', isError: true);
      }
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, scroll) => SingleChildScrollView(
          controller: scroll,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _privacyParagraph(
                'Data Storage',
                'All your data (transactions, wallets, categories, profile) is stored locally on your device only. We do not collect, transmit, or have access to any of your financial data.',
              ),
              _privacyParagraph(
                'Backups',
                'Backup files (.mbak) are saved to your device\'s local storage. It is your responsibility to keep these files safe.',
              ),
              _privacyParagraph(
                'Permissions',
                'The app may request camera or photo library access solely for profile pictures and category icons. These images stay on your device.',
              ),
              _privacyParagraph(
                'Third Parties',
                'This app does not integrate any third-party analytics, advertising, or tracking services.',
              ),
              _privacyParagraph(
                'Contact',
                'For questions, contact us through the app\'s store listing.',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _privacyParagraph(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    indent: 56,
                    color: Theme.of(context).dividerColor,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showChevron;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing:
          trailing ??
          (showChevron
              ? Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade400,
                )
              : null),
    );
  }
}
