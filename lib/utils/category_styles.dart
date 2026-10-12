import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../providers/category_provider.dart';

class CategoryStyle {
  final IconData icon;
  final Color color;
  final String? imagePath;

  const CategoryStyle(this.icon, this.color, {this.imagePath});
}

/// Safe icon mapper for release builds.
/// Avoids dynamic IconData() creation.
IconData _safeIcon(int codePoint) {
  return kCategoryIcons.firstWhere(
    (e) => e.codePoint == codePoint,
    orElse: () => Icons.label_outline,
  );
}

CategoryStyle styleForTransaction(
  TransactionModel tx, [
  List<CategoryModel> customCategories = const [],
]) {
  final lower = tx.category.toLowerCase();

  // ── Income ─────────────────────────────────────────────
  if (tx.type == TransactionType.income) {
    for (final c in customCategories) {
      if (c.type == 'income' && c.name.toLowerCase() == lower) {
        return CategoryStyle(
          _safeIcon(c.iconCodePoint),
          Color(c.colorValue),
          imagePath: c.imagePath,
        );
      }
    }

    for (final b in builtInCategories) {
      if (b.type == 'income' && b.name.toLowerCase() == lower) {
        return CategoryStyle(b.icon, b.color);
      }
    }

    return const CategoryStyle(Icons.monetization_on, Color(0xFF43A047));
  }

  // ── Expense ────────────────────────────────────────────
  for (final c in customCategories) {
    if (c.type == 'expense' && c.name.toLowerCase() == lower) {
      return CategoryStyle(
        _safeIcon(c.iconCodePoint),
        Color(c.colorValue),
        imagePath: c.imagePath,
      );
    }
  }

  for (final b in builtInCategories) {
    if (b.type == 'expense' && b.name.toLowerCase() == lower) {
      return CategoryStyle(b.icon, b.color);
    }
  }

  return const CategoryStyle(Icons.payments, Color(0xFF607D8B));
}
