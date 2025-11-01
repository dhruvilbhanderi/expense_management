import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ExpenseController>()
        ? Get.find<ExpenseController>()
        : Get.put(ExpenseController());

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: const Color(0xFF6C63FF),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: 'Category Breakdown'),
            const SizedBox(height: 12),

            /// Category Pie Chart
            Obx(() {
              final categoryExpenses = controller.getCategoryExpenses();
              if (categoryExpenses.isEmpty) {
                return const _EmptyState(message: 'No expense data available');
              }

              final total = categoryExpenses.values.fold(0.0, (a, b) => a + b);
              if (total <= 0) {
                return const _EmptyState(message: 'No expense amounts to display');
              }

              final entries = categoryExpenses.entries.toList();

              return Column(
                children: [
                  SizedBox(
                    height: 280,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 6,
                        centerSpaceRadius: 58,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {},
                        ),
                        sections: entries.map((e) {
                          final percent = (e.value / total) * 100;
                          return PieChartSectionData(
                            value: e.value,
                            color: _getCategoryColor(e.key),
                            title: '${percent.toStringAsFixed(1)}%',
                            radius: 80,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            badgeWidget: null,
                            showTitle: true,
                          );
                        }).toList(),
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 600),
                      swapAnimationCurve: Curves.easeOutCubic,
                    ),
                  ),
                  const SizedBox(height: 18),

                  /// Category Labels (legend-like)
                  ...entries.map((entry) {
                    final percent = (entry.value / total) * 100;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(entry.key),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '₹${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${percent.toStringAsFixed(1)}%)',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            }),

            const SizedBox(height: 36),

            _SectionTitle(title: 'Monthly Trend'),
            const SizedBox(height: 12),

            /// Monthly Income/Expense Bar Chart
            Obx(() {
              final transactions = controller.transactions;
              if (transactions.isEmpty) {
                return const _EmptyState(message: 'No transaction data available');
              }

              final now = DateTime.now();

              // Prepare last 6 months map: key -> {'income': 0.0, 'expense': 0.0}
              final monthlyData = <String, Map<String, double>>{};
              for (int i = 5; i >= 0; i--) {
                final date = DateTime(now.year, now.month - i, 1);
                final key = DateFormat('MMM').format(date);
                monthlyData[key] = {'income': 0.0, 'expense': 0.0};
              }

              // Group transactions safely (ensure t.type is 'income' or 'expense')
              for (var t in transactions) {
                final key = DateFormat('MMM').format(t.date);
                if (!monthlyData.containsKey(key)) continue;
                final type = (t.type == 'income' || t.type == 'expense') ? t.type : 'expense';
                monthlyData[key]![type] = (monthlyData[key]![type] ?? 0) + t.amount;
              }

              final months = monthlyData.keys.toList();
              // Compute maxY across income and expense; handle all-zero case
              double maxY = 0;
              for (var v in monthlyData.values) {
                final localMax = (v['income'] ?? 0) > (v['expense'] ?? 0) ? (v['income'] ?? 0) : (v['expense'] ?? 0);
                if (localMax > maxY) maxY = localMax;
              }
              if (maxY <= 0) maxY = 100; // fallback so chart has space

              // Build grouped bars
              final barGroups = <BarChartGroupData>[];
              int idx = 0;
              for (final entry in monthlyData.entries) {
                final income = entry.value['income'] ?? 0.0;
                final expense = entry.value['expense'] ?? 0.0;

                // We'll display two narrow bars side-by-side per group using different widths
                barGroups.add(
                  BarChartGroupData(
                    x: idx,
                    barsSpace: 6,
                    barRods: [
                      BarChartRodData(
                        toY: income,
                        width: 10,
                        borderRadius: BorderRadius.circular(6),
                        rodStackItems: [],
                        gradient: null,
                        // color fallback if gradient not allowed
                        color: Colors.green,
                      ),
                      BarChartRodData(
                        toY: expense,
                        width: 10,
                        borderRadius: BorderRadius.circular(6),
                        rodStackItems: [],
                        gradient: null,
                        color: Colors.red,
                      ),
                    ],
                    showingTooltipIndicators: [0, 1],
                  ),
                );
                idx++;
              }

              return Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY * 1.2,
                        groupsSpace: 18,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            // tooltipBgColor: Colors.grey.shade800,
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
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i >= 0 && i < months.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      months[i],
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
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
                                  return Text('₹${value.toInt()}',
                                      style: const TextStyle(fontSize: 12));
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: true, drawHorizontalLine: true, horizontalInterval: _niceInterval(maxY)),
                        barGroups: barGroups,
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 650),
                      swapAnimationCurve: Curves.easeOutExpo,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      _LegendItem(color: Colors.green, label: 'Income'),
                      SizedBox(width: 22),
                      _LegendItem(color: Colors.red, label: 'Expense'),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// return a friendly interval for y-axis ticks
  static double _niceInterval(double max) {
    // Make 4-6 ticks typically
    if (max <= 100) return 20;
    final step = (max / 5).roundToDouble();
    // round to nearest "nice" value: 10, 20, 50, 100...
    if (step <= 10) return 10;
    if (step <= 20) return 20;
    if (step <= 50) return 50;
    if (step <= 100) return 100;
    return (step / 100).round() * 100;
  }

  /// 🎨 Category Colors
  Color _getCategoryColor(String category) {
    final colors = {
      'Food': Colors.orange,
      'Transport': Colors.blue,
      'Shopping': Colors.purple,
      'Entertainment': Colors.pink,
      'Bills': Colors.red,
      'Health': Colors.green,
      'Education': Colors.teal,
      'Others': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }
}

/// 🔹 Legend Widget
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 2))],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Section Title
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36.0),
        child: Column(
          children: [
            Icon(Icons.insert_chart_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
