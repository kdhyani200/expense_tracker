import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';

/// Shared icon + colour for a transaction category or type.
class CategoryStyle {
  final IconData icon;
  final Color color;
  const CategoryStyle(this.icon, this.color);
}

/// Returns icon+color for a [TransactionModel] checking built-ins then
/// custom categories from Hive.  Pass [customCategories] from the provider.
CategoryStyle styleForTransaction(
  TransactionModel tx, [
  List<CategoryModel> customCategories = const [],
]) {
  final resolved = resolveCategory(tx.category, customCategories);
  return CategoryStyle(resolved.icon, resolved.color);
}
