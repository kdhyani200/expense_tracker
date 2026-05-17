import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';

/// Shared icon + colour + optional image for a transaction category or type.
class CategoryStyle {
  final IconData icon;
  final Color color;

  /// Set when the category was saved with a gallery image instead of an icon.
  final String? imagePath;

  const CategoryStyle(this.icon, this.color, {this.imagePath});
}

/// Returns icon+color+imagePath for a [TransactionModel] checking built-ins
/// then custom categories from Hive.  Pass [customCategories] from the provider.
CategoryStyle styleForTransaction(
  TransactionModel tx, [
  List<CategoryModel> customCategories = const [],
]) {
  final lower = tx.category.toLowerCase();

  // Income shortcut
  if (tx.type == TransactionType.income) {
    // Check custom income first (may have an image)
    for (final c in customCategories) {
      if (c.type == 'income' && c.name.toLowerCase() == lower) {
        return CategoryStyle(
          IconData(
            c.iconCodePoint == -1
                ? Icons.label_outline.codePoint
                : c.iconCodePoint,
            fontFamily: 'MaterialIcons',
          ),
          Color(c.colorValue),
          imagePath: c.imagePath,
        );
      }
    }
    // Built-in income
    for (final b in builtInCategories) {
      if (b.type == 'income' && b.name.toLowerCase() == lower) {
        return CategoryStyle(b.icon, b.color);
      }
    }
    // Fallback income icon
    return const CategoryStyle(Icons.monetization_on, Color(0xFF43A047));
  }

  // Expense — check custom first
  for (final c in customCategories) {
    if (c.type == 'expense' && c.name.toLowerCase() == lower) {
      return CategoryStyle(
        IconData(
          c.iconCodePoint == -1
              ? Icons.label_outline.codePoint
              : c.iconCodePoint,
          fontFamily: 'MaterialIcons',
        ),
        Color(c.colorValue),
        imagePath: c.imagePath,
      );
    }
  }

  // Built-in expense
  for (final b in builtInCategories) {
    if (b.type == 'expense' && b.name.toLowerCase() == lower) {
      return CategoryStyle(b.icon, b.color);
    }
  }

  return const CategoryStyle(Icons.payments, Color(0xFF607D8B));
}
