import 'package:flutter/material.dart';

class Transaction {
  final IconData icon;
  final Color color;
  final String label;
  final String description;
  final String amount;
  final DateTime date;
  final bool isIncome;

  Transaction({
    required this.icon,
    required this.color,
    required this.label,
    required this.description,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}

List<Transaction> recentTransactions = [
  Transaction(
    icon: Icons.favorite_rounded,
    color: const Color(0xFFE91E63),
    label: 'Health',
    description: 'checkup fee',
    amount: '25',
    date: DateTime(2026, 12, 11),
    isIncome: false,
  ),
  Transaction(
    icon: Icons.attach_money_rounded,
    color: Colors.green,
    label: 'Income',
    description: 'Gift from Family',
    amount: '60',
    date: DateTime(2026, 12, 10),
    isIncome: true,
  ),
  Transaction(
    icon: Icons.checkroom_rounded,
    color: Colors.deepPurpleAccent,
    label: 'Clothing',
    description: 'Winter Clothing',
    amount: '20',
    date: DateTime(2026, 12, 10),
    isIncome: false,
  ),
  Transaction(
    icon: Icons.attach_money_rounded,
    color: Colors.green,
    label: 'Income',
    description: 'Cashback from Credit Card',
    amount: '90',
    date: DateTime(2026, 12, 9),
    isIncome: true,
  ),
  Transaction(
    icon: Icons.restaurant_rounded,
    color: const Color(0xFFC2185B),
    label: 'Dining',
    description: 'Had dinner at hotel',
    amount: '50',
    date: DateTime(2026, 12, 8),
    isIncome: false,
  ),
  Transaction(
    icon: Icons.favorite_rounded,
    color: const Color(0xFFE91E63),
    label: 'Health',
    description: 'checkup fee',
    amount: '25',
    date: DateTime(2026, 12, 11),
    isIncome: false,
  ),
  Transaction(
    icon: Icons.attach_money_rounded,
    color: Colors.green,
    label: 'Income',
    description: 'Gift from Family',
    amount: '60',
    date: DateTime(2026, 12, 10),
    isIncome: true,
  ),
  Transaction(
    icon: Icons.checkroom_rounded,
    color: Colors.deepPurpleAccent,
    label: 'Clothing',
    description: 'Winter Clothing',
    amount: '20',
    date: DateTime(2026, 12, 10),
    isIncome: false,
  ),
  Transaction(
    icon: Icons.attach_money_rounded,
    color: Colors.green,
    label: 'Income',
    description: '',
    amount: '90',
    date: DateTime(2026, 12, 9),
    isIncome: true,
  ),
  Transaction(
    icon: Icons.restaurant_rounded,
    color: const Color(0xFFC2185B),
    label: 'Dining',
    description: 'Had dinner at hotel',
    amount: '50',
    date: DateTime(2026, 12, 8),
    isIncome: false,
  ),
];
