import 'package:expense_management/models/transaction_model.dart';
import 'package:expense_management/views/add_transaction_screen.dart';
import 'package:expense_management/views/statistics_screen.dart';
import 'package:expense_management/views/transactions_list_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  static const Color primaryColor = Color(0xFF6C63FF);

  // Centralized color map (keeps color sets consistent across app)
  static const Map<String, Color> _categoryColorMap = {
    'Food': Colors.orange,
    'Transport': Colors.blue,
    'Shopping': Colors.purple,
    'Entertainment': Colors.pink,
    'Bills': Colors.red,
    'Health': Colors.green,
    'Education': Colors.teal,
    'Others': Colors.grey,
    'Salary': Colors.blue,
    'Business': Colors.orange,
    'Investments': Colors.purple,
    'Freelance': Colors.red,
    'Gift': Colors.green,
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ExpenseController>()
        ? Get.find<ExpenseController>()
        : Get.put(ExpenseController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Statistics',
            icon:  Icon(Icons.bar_chart),
            onPressed: () => Get.to(() =>  StatisticsScreen()),
          ),
          // IconButton(
          //   tooltip: 'Refresh',
          //   icon: const Icon(Icons.refresh),
          //   onPressed: () => controller.loadTransactions(),
          // ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(controller),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSpendingOverviewHeader(controller),
                    const SizedBox(height: 20),
                    _buildSpendingPie(controller),
                    const SizedBox(height: 30),
                    _buildRecentTransactionsHeader(controller),
                    const SizedBox(height: 10),
                    _buildRecentTransactionsList(controller),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() =>  AddTransactionScreen()),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildHeader(ExpenseController controller) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 26),
        child: Column(
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              // controller.balance is computed from totalIncome - totalExpense
              final bal = controller.balance;
              return Text(
                '\$${bal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(
                  child: BalanceCard(
                    title: 'Income',
                    icon: Icons.arrow_downward,
                    color: Colors.green,
                    isIncome: true,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: BalanceCard(
                    title: 'Expense',
                    icon: Icons.arrow_upward,
                    color: Colors.red,
                    isIncome: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingOverviewHeader(ExpenseController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Spending Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Obx(() {
          const validFilters = ['All', 'Income', 'Expense'];
          final selectedValue = validFilters.contains(controller.selectedFilter.value)
              ? controller.selectedFilter.value
              : 'All';

          return DropdownButton<String>(
            value: selectedValue,
            items: validFilters
                .map((filter) => DropdownMenuItem(
              value: filter,
              child: Text(filter),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) controller.selectedFilter.value = value;
            },
          );
        }),
      ],
    );
  }

  Widget _buildSpendingPie(ExpenseController controller) {
    return Obx(() {
      final categoryExpenses = controller.getCategoryExpenses();
      if (categoryExpenses.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('No transactions yet'),
          ),
        );
      }

      final total = categoryExpenses.values.fold(0.0, (s, v) => s + v);
      if (total <= 0) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('No amounts to display'),
          ),
        );
      }

      final entries = categoryExpenses.entries.toList();

      return Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                pieTouchData: PieTouchData(enabled: true),
                sections: entries.map((entry) {
                  final percentage = (entry.value / total) * 100;
                  return PieChartSectionData(
                    value: entry.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    color: _categoryColorMap[entry.key] ?? Colors.grey,
                    radius: 58,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 600),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: entries.map((e) {
              final percent = (e.value / total) * 100;
              return _MiniLegendItem(
                color: _categoryColorMap[e.key] ?? Colors.grey,
                label: '${e.key} • ${percent.toStringAsFixed(0)}%',
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildRecentTransactionsHeader(ExpenseController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () => Get.to(() =>  TransactionsListScreen()),
          child: const Text('See All'),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsList(ExpenseController controller) {
    return Obx(() {
      final transactions = controller.filteredTransactions.take(5).toList();
      if (transactions.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No transactions yet'),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _TransactionTile(
            transaction: transaction,
            categoryColorMap: _categoryColorMap,
          );
        },
      );
    });
  }
}

/// Balance card (Income / Expense)
class BalanceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isIncome;

  const BalanceCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.isIncome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpenseController>();
    return Obx(() {
      final amount = isIncome ? controller.totalIncome : controller.totalExpense;
      final amountText = '\$${amount.toStringAsFixed(2)}';

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ]),
            const SizedBox(height: 12),
            Text(
              amountText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    });
  }
}

/// Mini legend used beneath pies
class _MiniLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _MiniLegendItem({Key? key, required this.color, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Transaction tile used in recent list
class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final Map<String, Color> categoryColorMap;

  const _TransactionTile({
    Key? key,
    required this.transaction,
    required this.categoryColorMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ExpenseController>()
        ? Get.find<ExpenseController>()
        : Get.put(ExpenseController());

    final icon = transaction.type == 'income'
        ? controller.incomeCategoryIcons[transaction.category] ?? Icons.more_horiz
        : controller.expenseCategoryIcons[transaction.category] ?? Icons.more_horiz;

    final color = categoryColorMap[transaction.category] ?? Colors.grey;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${transaction.category} • ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          '${transaction.type == 'expense' ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: transaction.type == 'expense' ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        onTap: () => Get.to(() => AddTransactionScreen(transaction: transaction)),
      ),
    );
  }
}
