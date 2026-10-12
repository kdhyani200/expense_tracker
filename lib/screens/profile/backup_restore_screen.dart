import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../providers/category_provider.dart';
import '../../providers/transactions_providers.dart';
import '../../providers/wallet_providers.dart';
import '../../services/data_services.dart';
import '../../services/permission_service.dart';
import '../../utils/snackbar_util.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  static const _dirKey = 'backupDirectory';

  List<File> _backupFiles = [];
  bool _loading = false;
  String? _saveDirectory;

  @override
  void initState() {
    super.initState();
    _saveDirectory = Hive.box('preferences').get(_dirKey) as String?;
    _loadBackupFiles();
  }

  Future<void> _loadBackupFiles() async {
    final granted = await PermissionService.requestStoragePermission();

    if (!granted) return;
    final files = await DataService.listBackups();
    if (mounted) setState(() => _backupFiles = files);
  }

  // ── Create backup ────────────────────────────────────────────────────────

  Future<void> _createBackup() async {
    setState(() => _loading = true);
    final granted = await PermissionService.requestStoragePermission();

    if (!granted) return;
    try {
      final path = await DataService.createBackup();
      await _loadBackupFiles();
      if (mounted) {
        _showSuccessDialog('Backup Created', path, isBackup: true);
        // Open share sheet so user can save to Downloads / Drive / etc.
        await DataService.openFile(path);
      }
    } catch (e) {
      if (mounted)
        SnackBarUtils.showSnackBar(context, 'Backup failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Restore — pick any .mbak file ────────────────────────────────────────

  Future<void> _pickAndRestore() async {
    final granted = await PermissionService.requestStoragePermission();

    if (!granted) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      dialogTitle: 'Select a .mbak backup file',
    );

    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;

    if (!path.endsWith('.mbak')) {
      if (mounted) {
        SnackBarUtils.showSnackBar(
          context,
          'Please select a valid .mbak file',
          isError: true,
        );
      }
      return;
    }

    await _restoreFromPath(path);
  }

  Future<void> _restoreFromPath(String filePath) async {
    final fileName = filePath.split('/').last;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Restore Backup?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will replace all current data with:\n\n$fileName\n\n'
          'Current data will be permanently overwritten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Restore', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      final count = await DataService.restoreBackup(filePath);
      ref.read(transactionsProvider.notifier).loadTransactions();
      ref.read(walletsProvider.notifier).loadWallets();
      ref.read(categoryProvider.notifier).loadCategories();
      if (mounted) {
        _showSuccessDialog(
          'Restore Complete',
          '$count transactions restored successfully.',
          isBackup: false,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showSnackBar(
          context,
          'Restore failed: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Change save/search directory ─────────────────────────────────────────

  Future<void> _changeDirectory() async {
    final granted = await PermissionService.requestStoragePermission();

    if (!granted) return;
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose backup folder',
    );
    if (result == null) return;

    await Hive.box('preferences').put(_dirKey, result);
    setState(() => _saveDirectory = result);
    await _loadBackupFiles();

    if (mounted) {
      SnackBarUtils.showSnackBar(
        context,
        'Backup folder set to: ${result.split('/').last}',
      );
    }
  }

  void _showSuccessDialog(
    String title,
    String detail, {
    required bool isBackup,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isBackup ? Icons.cloud_done : Icons.restore,
              color: const Color(0xFF00885d),
            ),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBackup) ...[
              const Text('Your data has been backed up to:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  detail,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Transfer the .mbak file to a safe place (cloud, PC) so you can restore it after reinstalling.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ] else
              Text(detail),
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
  }

  Future<void> _deleteBackupFile(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Backup?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Delete ${file.path.split('/').last}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await file.delete();
    _loadBackupFiles();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: BackButton(color: Theme.of(context).primaryColor),
        title: Text(
          'Backup & Restore',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              bottom: true,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Info banner ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00885d).withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF00885d).withValues(alpha: .2),
                      ),
                    ),
                    child: Text(
                      'Backups are saved as .mbak files. Move the file to a cloud drive or PC for safekeeping. To restore after reinstalling, pick the file with the Restore button.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Current directory ───────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: .8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          color: Colors.grey.shade300,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _saveDirectory != null
                                ? _saveDirectory!
                                : 'Default: Downloads / Documents',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Three action buttons ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.backup_rounded,
                          label: 'Create\nBackup',
                          color: const Color(0xFF00885d),
                          onTap: _createBackup,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.restore_rounded,
                          label: 'Restore\nBackup',
                          color: Colors.orange,
                          onTap: _pickAndRestore,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.folder_open_rounded,
                          label: 'Change\nFolder',
                          color: Colors.indigo,
                          onTap: _changeDirectory,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Local backup list ───────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Saved Backups',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_backupFiles.length} file${_backupFiles.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_backupFiles.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 56,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No backups in this folder',
                              style: TextStyle(color: Colors.grey.shade300),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a backup or change the folder',
                              style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._backupFiles.map((file) {
                      final name = file.path.split('/').last;
                      final modified = file.lastModifiedSync();
                      final sizeKb = (file.lengthSync() / 1024).toStringAsFixed(
                        1,
                      );
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF00885d,
                              ).withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.insert_drive_file,
                              color: Color(0xFF00885d),
                              size: 22,
                            ),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${fmt.format(modified)} · $sizeKb KB',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.restore_rounded,
                                  color: Color(0xFF00885d),
                                  size: 22,
                                ),
                                onPressed: () => _restoreFromPath(file.path),
                                tooltip: 'Restore',
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade300,
                                  size: 22,
                                ),
                                onPressed: () => _deleteBackupFile(file),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
