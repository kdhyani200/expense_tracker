import 'package:flutter/material.dart';

import '../models/transaction_model.dart';

class CategoryStyle {
  final IconData icon;
  final Color color;
  const CategoryStyle(this.icon, this.color);
}

const Map<String, CategoryStyle> categoryStyles = {
  'food': CategoryStyle(Icons.restaurant, Color(0xFF4CAF50)),
  'travel': CategoryStyle(Icons.flight_takeoff, Color(0xFF2196F3)),
  'transport': CategoryStyle(Icons.directions_bus, Color(0xFF2196F3)),
  'shopping': CategoryStyle(Icons.shopping_bag, Color(0xFFFF9800)),
  'bills': CategoryStyle(Icons.receipt_long, Color(0xFF9C27B0)),
  'entertainment': CategoryStyle(Icons.movie, Color(0xFFE91E63)),
  'health': CategoryStyle(Icons.medical_services, Color(0xFFF44336)),
  'clothing': CategoryStyle(Icons.checkroom, Color(0xFF00BCD4)),
  'education': CategoryStyle(Icons.school, Color(0xFF3F51B5)),
  'other': CategoryStyle(Icons.miscellaneous_services, Color(0xFF607D8B)),
};

const CategoryStyle _fallbackExpense = CategoryStyle(
  Icons.payments,
  Color(0xFF607D8B),
);
const CategoryStyle _incomeStyle = CategoryStyle(
  Icons.monetization_on,
  Color(0xFF43A047),
);

CategoryStyle styleForTransaction(TransactionModel tx) {
  if (tx.type == TransactionType.income) return _incomeStyle;
  return categoryStyles[tx.category.toLowerCase()] ?? _fallbackExpense;
}
