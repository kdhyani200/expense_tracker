import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

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
