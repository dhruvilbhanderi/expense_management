import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  static const Color primaryColor = Color(0xFF6C63FF);

  static const Map<String, Color> categoryColorMap = {
    'Food': Color(0xFFFF6B6B),
    'Transport': Color(0xFF4ECDC4),
    'Shopping': Color(0xFF9B59B6),
    'Entertainment': Color(0xFFFF9FF3),
    'Bills': Color(0xFFFF4757),
    'Health': Color(0xFF51CF66),
    'Education': Color(0xFF339AF0),
    'Others': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ExpenseController>()
        ? Get.find<ExpenseController>()
        : Get.put(ExpenseController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                color: primaryColor,
                onPressed: () => Get.back(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.8),
                      const Color(0xFF9575CD),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.analytics,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistics',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Track your spending insights',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryBreakdown(controller),
                  const SizedBox(height: 24),
                  _buildMonthlyTrend(controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(ExpenseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Breakdown',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 20),
        Obx(() {
          final categoryExpenses = controller.getCategoryExpenses();
          if (categoryExpenses.isEmpty) {
            return _buildEmptyState(
              icon: Icons.pie_chart_outline,
              message: 'No expense data available',
            );
          }

          final total = categoryExpenses.values.fold(0.0, (a, b) => a + b);
          if (total <= 0) {
            return _buildEmptyState(
              icon: Icons.insert_chart_outlined,
              message: 'No expense amounts to display',
            );
          }

          final entries = categoryExpenses.entries.toList();
          entries.sort((a, b) => b.value.compareTo(a.value));

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 70,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, baseTouchResponse) {},
                      ),
                      sections: entries.map((e) {
                        final percent = (e.value / total) * 100;
                        return PieChartSectionData(
                          value: e.value,
                          color: categoryColorMap[e.key] ?? Colors.grey,
                          title: percent > 5 ? '${percent.toStringAsFixed(1)}%' : '',
                          radius: 90,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      }).toList(),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 800),
                    swapAnimationCurve: Curves.easeInOutCubic,
                  ),
                ),
                const SizedBox(height: 24),
                ...entries.map((entry) {
                  final percent = (entry.value / total) * 100;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCategoryItem(entry.key, entry.value, percent),
                  );
                }).toList(),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCategoryItem(String category, double amount, double percent) {
    final color = categoryColorMap[category] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.category,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${percent.toStringAsFixed(1)}% of total',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrend(ExpenseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Trend',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 20),
        Obx(() {
          final transactions = controller.transactions;
          if (transactions.isEmpty) {
            return _buildEmptyState(
              icon: Icons.bar_chart_outlined,
              message: 'No transaction data available',
            );
          }

          final now = DateTime.now();
          final monthlyData = <String, Map<String, double>>{};
          for (int i = 5; i >= 0; i--) {
            final date = DateTime(now.year, now.month - i, 1);
            final key = DateFormat('MMM').format(date);
            monthlyData[key] = {'income': 0.0, 'expense': 0.0};
          }

          for (var t in transactions) {
            final key = DateFormat('MMM').format(t.date);
            if (!monthlyData.containsKey(key)) continue;
            final type = (t.type == 'income' || t.type == 'expense') ? t.type : 'expense';
            monthlyData[key]![type] = (monthlyData[key]![type] ?? 0) + t.amount;
          }

          final months = monthlyData.keys.toList();
          double maxY = 0;
          for (var v in monthlyData.values) {
            final localMax = (v['income'] ?? 0) > (v['expense'] ?? 0) ? (v['income'] ?? 0) : (v['expense'] ?? 0);
            if (localMax > maxY) maxY = localMax;
          }
          if (maxY <= 0) maxY = 100;

          final barGroups = <BarChartGroupData>[];
          int idx = 0;
          for (final entry in monthlyData.entries) {
            final income = entry.value['income'] ?? 0.0;
            final expense = entry.value['expense'] ?? 0.0;

            barGroups.add(
              BarChartGroupData(
                x: idx,
                barsSpace: 8,
                barRods: [
                  BarChartRodData(
                    toY: income,
                    width: 14,
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF2ECC71),
                  ),
                  BarChartRodData(
                    toY: expense,
                    width: 14,
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFFF4757),
                  ),
                ],
              ),
            );
            idx++;
          }

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 320,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY * 1.2,
                      groupsSpace: 20,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final month = months[group.x.toInt()];
                            final value = rod.toY;
                            final label = rodIndex == 0 ? 'Income' : 'Expense';
                            return BarTooltipItem(
                              '$month\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: '$label: ₹${value.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i >= 0 && i < months.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    months[i],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: _niceInterval(maxY),
                            reservedSize: 56,
                            getTitlesWidget: (value, meta) {
                              if (value % (_niceInterval(maxY)) == 0) {
                                return Text(
                                  '₹${value.toInt()}',
                                  style: const TextStyle(fontSize: 12),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        horizontalInterval: _niceInterval(maxY),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      barGroups: barGroups,
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 650),
                    swapAnimationCurve: Curves.easeOutExpo,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(color: const Color(0xFF2ECC71), label: 'Income'),
                    const SizedBox(width: 32),
                    _LegendItem(color: const Color(0xFFFF4757), label: 'Expense'),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static double _niceInterval(double max) {
    if (max <= 100) return 20;
    final step = (max / 5).roundToDouble();
    if (step <= 10) return 10;
    if (step <= 20) return 20;
    if (step <= 50) return 50;
    if (step <= 100) return 100;
    return (step / 100).round() * 100;
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
