import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../services/hive_service.dart';

// ── Built-in categories (never stored in Hive — always present) ────────────

class BuiltInCategory {
  final String name;
  final IconData icon;
  final Color color;
  final String type; // 'income' or 'expense'
  const BuiltInCategory(this.name, this.icon, this.color, this.type);
}

const List<BuiltInCategory> builtInCategories = [
  // Expense
  BuiltInCategory('Food', Icons.restaurant, Color(0xFF4CAF50), 'expense'),
  BuiltInCategory('Shopping', Icons.shopping_bag, Color(0xFFFF9800), 'expense'),
  BuiltInCategory(
    'Transport',
    Icons.directions_bus,
    Color(0xFF2196F3),
    'expense',
  ),
  BuiltInCategory('Bills', Icons.receipt_long, Color(0xFF9C27B0), 'expense'),
  BuiltInCategory('Entertainment', Icons.movie, Color(0xFFE91E63), 'expense'),
  BuiltInCategory(
    'Health',
    Icons.medical_services,
    Color(0xFFF44336),
    'expense',
  ),
  BuiltInCategory('Clothing', Icons.checkroom, Color(0xFF00BCD4), 'expense'),
  BuiltInCategory('Education', Icons.school, Color(0xFF3F51B5), 'expense'),
  BuiltInCategory('Travel', Icons.flight_takeoff, Color(0xFF2196F3), 'expense'),
  BuiltInCategory(
    'Other',
    Icons.miscellaneous_services,
    Color(0xFF607D8B),
    'expense',
  ),
  // Income
  BuiltInCategory('Salary', Icons.work, Color(0xFF43A047), 'income'),
  BuiltInCategory('Freelance', Icons.laptop_mac, Color(0xFF00ACC1), 'income'),
  BuiltInCategory('Investment', Icons.trending_up, Color(0xFF7CB342), 'income'),
  BuiltInCategory('Business', Icons.store, Color(0xFFFB8C00), 'income'),
  BuiltInCategory('Gift', Icons.card_giftcard, Color(0xFFE91E63), 'income'),
  BuiltInCategory('Rental', Icons.home_work, Color(0xFF8E24AA), 'income'),
  BuiltInCategory('Refund', Icons.replay, Color(0xFF039BE5), 'income'),
  BuiltInCategory(
    'Other Income',
    Icons.attach_money,
    Color(0xFF00897B),
    'income',
  ),
];

// ── Notifier ────────────────────────────────────────────────────────────────

class CategoryNotifier extends Notifier<List<CategoryModel>> {
  @override
  List<CategoryModel> build() => _load();

  List<CategoryModel> _load() => HiveService.categoryBox.values.toList();

  void loadCategories() => state = _load();

  Future<void> addCategory(CategoryModel cat) async {
    await HiveService.categoryBox.put(cat.id, cat);
    state = _load();
  }

  Future<void> deleteCategory(String id) async {
    await HiveService.categoryBox.delete(id);
    state = _load();
  }

  /// All category names for a given type (built-in + custom).
  List<String> namesFor(String type) {
    final builtin = builtInCategories
        .where((c) => c.type == type)
        .map((c) => c.name)
        .toList();
    final custom = state
        .where((c) => c.type == type)
        .map((c) => c.name)
        .toList();
    return [...builtin, ...custom];
  }
}

final categoryProvider =
    NotifierProvider<CategoryNotifier, List<CategoryModel>>(
      CategoryNotifier.new,
    );

// ── Helpers shared across UI ────────────────────────────────────────────────

/// Looks up icon + color for [name] across built-ins then custom Hive cats.
({IconData icon, Color color}) resolveCategory(
  String name,
  List<CategoryModel> custom,
) {
  final lower = name.toLowerCase();

  // Built-in categories
  for (final b in builtInCategories) {
    if (b.name.toLowerCase() == lower) {
      return (icon: b.icon, color: b.color);
    }
  }

  // Custom categories
  for (final c in custom) {
    if (c.name.toLowerCase() == lower) {
      return (
        icon: _iconFromCodePoint(c.iconCodePoint),
        color: Color(c.colorValue),
      );
    }
  }

  return (icon: Icons.label_outline, color: const Color(0xFF607D8B));
}

/// Converts saved icon codePoint safely to IconData.
/// This fixes release build crash caused by dynamic IconData().
IconData _iconFromCodePoint(int codePoint) {
  final icon = kCategoryIcons.firstWhere(
    (e) => e.codePoint == codePoint,
    orElse: () => Icons.label_outline,
  );

  return icon;
}

/// Palette of color options shown in the add-category dialog.
const List<Color> kCategoryColors = [
  Color(0xFF4CAF50),
  Color(0xFFFF9800),
  Color(0xFF2196F3),
  Color(0xFF9C27B0),
  Color(0xFFE91E63),
  Color(0xFFF44336),
  Color(0xFF00BCD4),
  Color(0xFF3F51B5),
  Color(0xFF43A047),
  Color(0xFFFB8C00),
  Color(0xFF039BE5),
  Color(0xFF8E24AA),
  Color(0xFF607D8B),
  Color(0xFF00897B),
  Color(0xFFD81B60),
  Color(0xFF546E7A),
];

/// Preset icons available in the add-category dialog.
const List<IconData> kCategoryIcons = [
  Icons.restaurant,
  Icons.shopping_bag,
  Icons.directions_bus,
  Icons.receipt_long,
  Icons.movie,
  Icons.medical_services,
  Icons.checkroom,
  Icons.school,
  Icons.flight_takeoff,
  Icons.miscellaneous_services,
  Icons.work,
  Icons.laptop_mac,
  Icons.trending_up,
  Icons.store,
  Icons.card_giftcard,
  Icons.home_work,
  Icons.replay,
  Icons.attach_money,
  Icons.sports_soccer,
  Icons.fitness_center,
  Icons.coffee,
  Icons.local_grocery_store,
  Icons.directions_car,
  Icons.train,
  Icons.pets,
  Icons.child_care,
  Icons.music_note,
  Icons.book,
  Icons.camera_alt,
  Icons.games,
  Icons.spa,
  Icons.volunteer_activism,
  Icons.savings,
];
