import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final uuid = const Uuid();

enum Type { Expense, Income }

enum ExpenseCategory {
  food,
  travel,
  shopping,
  bills,
  entertainment,
  health,
  clothing,
  other,
}

class Transaction {
  final Type type;
  final String id;
  final String wallet;
  final ExpenseCategory category;
  final DateTime date;
  final String amount;
  final String? description;

  Transaction({
    required this.type,
    required this.wallet,
    required this.category,
    required this.date,
    required this.amount,
    this.description,
  }) : id = uuid.v4();
}

extension CategoryExtension on ExpenseCategory {
  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFF4CAF50); // Green
      case ExpenseCategory.travel:
        return const Color(0xFF2196F3); // Blue
      case ExpenseCategory.shopping:
        return const Color(0xFFFF9800); // Orange
      case ExpenseCategory.bills:
        return const Color(0xFF9C27B0); // Purple
      case ExpenseCategory.entertainment:
        return const Color(0xFFE91E63); // Pink
      case ExpenseCategory.health:
        return const Color(0xFFF44336); // Red
      case ExpenseCategory.clothing:
        return const Color(0xFF00BCD4); // Cyan
      case ExpenseCategory.other:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.travel:
        return Icons.flight_takeoff;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.bills:
        return Icons.receipt_long;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.health:
        return Icons.medical_services;
      case ExpenseCategory.clothing:
        return Icons.checkroom;
      case ExpenseCategory.other:
        return Icons.miscellaneous_services;
    }
  }
}
