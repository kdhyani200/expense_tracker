import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../providers/transactions_providers.dart';
import '../../widget/transactions_card.dart';

enum StatsType { weekly, monthly, yearly }

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  StatsType _selected = StatsType.weekly;
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.05,
        ),
        child: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.05,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Statistics",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildSwitcher(),
          const SizedBox(height: 12),
          _buildChart(transactions),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "All Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: transactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (_, i) =>
                        TransactionItemCard(transaction: transactions[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTab("Weekly", StatsType.weekly),
          _buildTab("Monthly", StatsType.monthly),
          _buildTab("Yearly", StatsType.yearly),
        ],
      ),
    );
  }

  Widget _buildTab(String title, StatsType type) {
    final selected = _selected == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selected = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF01734f).withValues(alpha: .3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: selected
                  ? Color(0xFF01734f)
                  : Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List<TransactionModel> transactions) {
    final chartData = _generateChartData(transactions);
    final maxValue = _calculateMax(chartData);

    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(top: 24, left: 12, right: 20, bottom: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF0f172a) : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: max(
            chartData.length * 90.0,
            MediaQuery.of(context).size.width - 32,
          ),
          child: BarChart(
            BarChartData(
              maxY: maxValue.toDouble(),
              alignment: BarChartAlignment.start,
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: maxValue / 5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Theme.of(context).dividerColor,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 72,
                    interval: maxValue / 5,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        "₹${value.toInt()}",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= chartData.length) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          chartData[index].label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem(
                        "₹${rod.toY.toStringAsFixed(0)}",
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
              barGroups: List.generate(chartData.length, (index) {
                final item = chartData[index];
                return BarChartGroupData(
                  x: index,
                  barsSpace: 10,
                  barRods: [
                    BarChartRodData(
                      toY: item.income,
                      width: 16,
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF10b981),
                    ),
                    BarChartRodData(
                      toY: item.expense,
                      width: 16,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.redAccent,
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  int _calculateMax(List<_ChartData> data) {
    double highest = 0;
    for (final item in data) {
      if (item.income > highest) highest = item.income;
      if (item.expense > highest) highest = item.expense;
    }
    if (highest <= 1000) return 1000;
    final raw = highest * 1.2;
    final step = _getStep(raw);
    return ((raw / step).ceil()) * step;
  }

  int _getStep(double value) {
    if (value <= 5000) return 1000;
    if (value <= 10000) return 2000;
    if (value <= 50000) return 5000;
    if (value <= 100000) return 10000;
    if (value <= 500000) return 50000;
    return 100000;
  }

  List<_ChartData> _generateChartData(List<TransactionModel> transactions) {
    final now = DateTime.now();

    // ── kly: today on left → 6 days ago on right ──────────────────────
    if (_selected == StatsType.weekly) {
      return List.generate(7, (index) {
        final date = now.subtract(Duration(days: index));
        double income = 0, expense = 0;
        for (final tx in transactions) {
          if (_isSameDay(tx.date, date)) {
            tx.type == TransactionType.income
                ? income += tx.amount
                : expense += tx.amount;
          }
        }
        return _ChartData(
          label: DateFormat('E').format(date),
          income: income,
          expense: expense,
        );
      });
    }

    // ── Monthly: today on left → 1st of month on right ───────────────────
    if (_selected == StatsType.monthly) {
      final firstDay = DateTime(now.year, now.month, 1);
      final dayCount = now.difference(firstDay).inDays + 1;

      return List.generate(dayCount, (index) {
        final date = now.subtract(Duration(days: index));
        double income = 0, expense = 0;
        for (final tx in transactions) {
          if (_isSameDay(tx.date, date)) {
            tx.type == TransactionType.income
                ? income += tx.amount
                : expense += tx.amount;
          }
        }
        return _ChartData(
          label: DateFormat('d MMM').format(date),
          income: income,
          expense: expense,
        );
      });
    }

    // ── Yearly: current year on left → 4 years ago on right ─────────────
    return List.generate(4, (index) {
      final year = now.year - index;
      double income = 0, expense = 0;
      for (final tx in transactions) {
        if (tx.date.year == year) {
          tx.type == TransactionType.income
              ? income += tx.amount
              : expense += tx.amount;
        }
      }
      return _ChartData(
        label: year.toString(),
        income: income,
        expense: expense,
      );
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.day == b.day && a.month == b.month && a.year == b.year;

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text(
            "No transactions yet",
            style: TextStyle(
              color: Colors.grey.shade300,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  final String label;
  final double income;
  final double expense;
  _ChartData({
    required this.label,
    required this.income,
    required this.expense,
  });
}
