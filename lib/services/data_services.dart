import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../models/user_model.dart';
import 'hive_service.dart';

/// Handles CSV export, .mbak backup, and .mbak restore.
class DataService {
  // ── CSV Export ─────────────────────────────────────────────────────────────

  /// Writes all transactions to a CSV file and returns its path.
  static Future<String> exportCsv() async {
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
        '${fmt.format(tx.date)},$type,${tx.category},$wallet,${tx.amount.toStringAsFixed(2)},$note',
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/trackkar_export_$timestamp.csv');
    await file.writeAsString(buf.toString());
    return file.path;
  }

  // ── Backup ─────────────────────────────────────────────────────────────────

  /// Serialises all boxes to JSON, writes to a .mbak file, returns path.
  static Future<String> createBackup() async {
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
            'iconIndex': c.iconCodePoint,
            'colorValue': c.colorValue,
            'type': c.type,
            'imagePath': c.imagePath,
          },
        )
        .toList();

    final user = HiveService.userBox.values.isNotEmpty
        ? {
            'firstName': HiveService.userBox.values.first.firstName,
            'lastName': HiveService.userBox.values.first.lastName,
            'imagePath': HiveService.userBox.values.first.imagePath,
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

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/trackkar_backup_$timestamp.mbak');
    await file.writeAsString(payload);
    return file.path;
  }

  // ── Restore ────────────────────────────────────────────────────────────────

  /// Reads a .mbak file, clears all boxes, and restores data.
  /// Returns the number of transactions restored, or throws on error.
  static Future<int> restoreBackup(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) throw Exception('File not found: $filePath');
    if (!filePath.endsWith('.mbak')) throw Exception('Not a valid .mbak file');

    final raw = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(raw);

    if (data['version'] != 1) {
      throw Exception('Unsupported backup version: ${data['version']}');
    }

    // ── Clear existing data ────────────────────────────────────────────────
    await HiveService.transactionBox.clear();
    await HiveService.walletBox.clear();
    await HiveService.categoryBox.clear();
    // Keep user — restore it separately below

    // ── Restore wallets ───────────────────────────────────────────────────
    for (final raw in (data['wallets'] as List)) {
      final w = WalletModel(
        id: raw['id'],
        name: raw['name'],
        balance: (raw['balance'] as num).toDouble(),
        imagePath: raw['imagePath'],
        createdAt: DateTime.parse(raw['createdAt']),
      );
      await HiveService.walletBox.put(w.id, w);
    }

    // ── Restore transactions ──────────────────────────────────────────────
    for (final raw in (data['transactions'] as List)) {
      final tx = TransactionModel(
        id: raw['id'],
        walletId: raw['walletId'],
        title: raw['title'] ?? raw['category'],
        amount: (raw['amount'] as num).toDouble(),
        category: raw['category'],
        type: raw['type'] == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        date: DateTime.parse(raw['date']),
        note: raw['note'] ?? '',
      );
      await HiveService.transactionBox.put(tx.id, tx);
    }

    // ── Restore categories ────────────────────────────────────────────────
    for (final raw in (data['categories'] as List)) {
      final c = CategoryModel(
        id: raw['id'],
        name: raw['name'],
        iconCodePoint: raw['iconIndex'] as int,
        colorValue: raw['colorValue'] as int,
        type: raw['type'],
        imagePath: raw['imagePath'],
      );
      await HiveService.categoryBox.put(c.id, c);
    }

    // ── Restore user ──────────────────────────────────────────────────────
    if (data['user'] != null) {
      final u = data['user'];
      await HiveService.userBox.clear();
      final userModel = UserModel(
        firstName: u['firstName'],
        lastName: u['lastName'],
        imagePath: u['imagePath'],
      );
      await HiveService.userBox.add(userModel);
    }

    return (data['transactions'] as List).length;
  }

  // ── Delete helpers ─────────────────────────────────────────────────────────

  static Future<void> deleteAllRecords() async {
    await HiveService.transactionBox.clear();
    // Reset all wallet balances to 0
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
  }
}
