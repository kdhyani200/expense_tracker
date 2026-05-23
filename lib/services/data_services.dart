import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../models/user_model.dart';
import 'hive_service.dart';

class DataService {
  // ── Save directory ──────────────────────────────────────────────────────────

  /// Always returns the app's private documents directory.
  /// This requires zero permissions on all Android versions and is always
  /// writable.  After saving, we call [openFile] so the user can share/copy
  /// the file to wherever they want via the system share sheet.
  static Future<Directory> _saveDir([String? customPath]) async {
    if (customPath != null && customPath.isNotEmpty) {
      final dir = Directory(customPath);

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      return dir;
    }

    return await getApplicationDocumentsDirectory();
  }

  /// Opens a file with the system viewer / share sheet so the user can
  /// save it to Downloads, Google Drive, WhatsApp, etc.
  static Future<void> openFile(String path) async {
    await OpenFilex.open(path);
  }

  // ── CSV Export ──────────────────────────────────────────────────────────────

  static Future<String> exportCsv([String? saveDirPath]) async {
    final transactions = HiveService.transactionBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final buf = StringBuffer();
    buf.writeln('Date,Type,Category,Wallet,Amount,Note');

    final wallets = {
      for (final w in HiveService.walletBox.values) w.id: w.name,
    };

    final fmt = DateFormat('yyyy-MM-dd');

    for (final tx in transactions) {
      final wallet = wallets[tx.walletId] ?? tx.walletId;
      final type = tx.type == TransactionType.income ? 'Income' : 'Expense';

      final note = tx.note.replaceAll(',', ';').replaceAll('\n', ' ');

      buf.writeln(
        '${fmt.format(tx.date)},'
        '$type,'
        '${tx.category},'
        '$wallet,'
        '${tx.amount.toStringAsFixed(2)},'
        '$note',
      );
    }

    final dir = await _saveDir(saveDirPath);

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    final file = File('${dir.path}/TrackKar_export_$timestamp.csv');

    await file.writeAsString(buf.toString());

    return file.path;
  }

  // ── Backup ──────────────────────────────────────────────────────────────────

  static Future<String> createBackup([String? saveDirPath]) async {
    final transactions = HiveService.transactionBox.values
        .map(
          (tx) => {
            'id': tx.id,
            'walletId': tx.walletId,
            'title': tx.title,
            'amount': tx.amount,
            'category': tx.category,
            'type': tx.type == TransactionType.income ? 'income' : 'expense',
            'date': tx.date.toIso8601String(),
            'note': tx.note,
          },
        )
        .toList();

    final wallets = HiveService.walletBox.values
        .map(
          (w) => {
            'id': w.id,
            'name': w.name,
            'balance': w.balance,
            'imagePath': w.imagePath,
            'createdAt': w.createdAt.toIso8601String(),
          },
        )
        .toList();

    final categories = HiveService.categoryBox.values
        .map(
          (c) => {
            'id': c.id,
            'name': c.name,
            'iconCodePoint': c.iconCodePoint,
            'colorValue': c.colorValue,
            'type': c.type,
            'imagePath': c.imagePath,
          },
        )
        .toList();

    final userList = HiveService.userBox.values.toList();

    final user = userList.isNotEmpty
        ? {
            'firstName': userList.first.firstName,
            'lastName': userList.first.lastName,
            'imagePath': userList.first.imagePath,
          }
        : null;

    final payload = jsonEncode({
      'version': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'transactions': transactions,
      'wallets': wallets,
      'categories': categories,
      if (user != null) 'user': user,
    });

    final dir = await _saveDir(saveDirPath);

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    final file = File('${dir.path}/TrackKar_backup_$timestamp.mbak');

    await file.writeAsString(payload);

    return file.path;
  }

  // ── Restore ─────────────────────────────────────────────────────────────────

  static Future<int> restoreBackup(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) throw Exception('File not found: $filePath');
    if (!filePath.endsWith('.mbak')) throw Exception('Not a valid .mbak file');

    final Map<String, dynamic> data = jsonDecode(await file.readAsString());
    if (data['version'] != 1) throw Exception('Unsupported backup version');

    await HiveService.transactionBox.clear();
    await HiveService.walletBox.clear();
    await HiveService.categoryBox.clear();

    for (final r in (data['wallets'] as List)) {
      final w = WalletModel(
        id: r['id'],
        name: r['name'],
        balance: (r['balance'] as num).toDouble(),
        imagePath: r['imagePath'],
        createdAt: DateTime.parse(r['createdAt']),
      );
      await HiveService.walletBox.put(w.id, w);
    }

    for (final r in (data['transactions'] as List)) {
      final tx = TransactionModel(
        id: r['id'],
        walletId: r['walletId'],
        title: r['title'] ?? r['category'],
        amount: (r['amount'] as num).toDouble(),
        category: r['category'],
        type: r['type'] == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        date: DateTime.parse(r['date']),
        note: r['note'] ?? '',
      );
      await HiveService.transactionBox.put(tx.id, tx);
    }

    for (final r in (data['categories'] as List)) {
      final c = CategoryModel(
        id: r['id'],
        name: r['name'],
        iconCodePoint: (r['iconCodePoint'] ?? r['iconIndex'] ?? 0) as int,
        colorValue: r['colorValue'] as int,
        type: r['type'],
        imagePath: r['imagePath'],
      );
      await HiveService.categoryBox.put(c.id, c);
    }

    if (data['user'] != null) {
      final u = data['user'];
      await HiveService.userBox.clear();
      await HiveService.userBox.put(
        'current_user',
        UserModel(
          firstName: u['firstName'],
          lastName: u['lastName'],
          imagePath: u['imagePath'],
        ),
      );
    }

    return (data['transactions'] as List).length;
  }

  // ── List saved backups ───────────────────────────────────────────────────────

  static Future<List<File>> listBackups([String? dirPath]) async {
    final dir = await _saveDir(dirPath);
    try {
      return dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.mbak'))
          .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    } catch (_) {
      return [];
    }
  }

  // ── Delete helpers ───────────────────────────────────────────────────────────

  static Future<void> deleteAllRecords() async {
    await HiveService.transactionBox.clear();
    for (final w in HiveService.walletBox.values) {
      w.balance = 0;
      await w.save();
    }
  }

  static Future<void> deleteEverything() async {
    await HiveService.transactionBox.clear();
    await HiveService.walletBox.clear();
    await HiveService.categoryBox.clear();
  }

  static Future<void> resetApp() async {
    await HiveService.transactionBox.clear();
    await HiveService.walletBox.clear();
    await HiveService.categoryBox.clear();
    await HiveService.userBox.clear();

    final prefs = Hive.box('preferences');
    await prefs.clear();
  }
}
