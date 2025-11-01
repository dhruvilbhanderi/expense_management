import 'package:expense_management/models/transaction_model.dart';
import 'package:expense_management/views/add_transaction_screen.dart';
import 'package:expense_management/views/statistics_screen.dart';
import 'package:expense_management/views/transactions_list_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color primaryColor = Color(0xFF6C63FF);
  
  // Local filter state for dashboard - independent from other screens
  var _dashboardFilter = 'All'.obs;

  // Centralized color map (keeps color sets consistent across app)
  static const Map<String, Color> _categoryColorMap = {
    'Food': Color(0xFFFF6B6B),
    'Transport': Color(0xFF4ECDC4),
    'Shopping': Color(0xFF9B59B6),
    'Entertainment': Color(0xFFFF9FF3),
    'Bills': Color(0xFFFF4757),
    'Health': Color(0xFF51CF66),
    'Education': Color(0xFF339AF0),
    'Others': Colors.grey,
    'Salary': Color(0xFF2ECC71),
    'Business': Color(0xFFFFA502),
    'Investments': Color(0xFF5F27CD),
    'Freelance': Color(0xFF00D2D3),
    'Gift': Color(0xFF26C6DA),
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ExpenseController>()
        ? Get.find<ExpenseController>()
        : Get.put(ExpenseController());

    return Scaffold(
      backgroundColor:  Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics:  BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            // shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
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
                  padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, MMMM d').format(DateTime.now()),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                          onPressed: () => Get.to(() => const StatisticsScreen()),
                          tooltip: 'Statistics',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildBalanceCard(controller),
                const SizedBox(height: 24),
                _buildQuickStats(controller),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildSpendingOverview(controller),
                const SizedBox(height: 24),
                _buildRecentTransactionsSection(controller),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildBalanceCard(ExpenseController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              const Color(0xFF9575CD),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
                final bal = controller.balance;
                return Text(
                  '₹${bal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                );
              }),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _ModernBalanceCard(
                      title: 'Income',
                      icon: Icons.trending_up,
                      color: const Color(0xFF2ECC71),
                      isIncome: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ModernBalanceCard(
                      title: 'Expense',
                      icon: Icons.trending_down,
                      color: const Color(0xFFFF4757),
                      isIncome: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(ExpenseController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final todayEnd = today.add(const Duration(days: 1));
            final weekStart = today.subtract(Duration(days: now.weekday - 1));
            final monthStart = DateTime(now.year, now.month, 1);

            double todayExpense = 0;
            double weekExpense = 0;
            double monthExpense = 0;

            for (var tx in controller.transactions) {
              if (tx.type == 'expense') {
                final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
                // Today's expenses
                if (txDate.isAtSameMomentAs(today)) {
                  todayExpense += tx.amount;
                }
                // This week's expenses (including today)
                if (tx.date.isAfter(weekStart.subtract(const Duration(days: 1))) && 
                    tx.date.isBefore(todayEnd)) {
                  weekExpense += tx.amount;
                }
                // This month's expenses
                if (tx.date.isAfter(monthStart.subtract(const Duration(days: 1))) && 
                    tx.date.isBefore(todayEnd)) {
                  monthExpense += tx.amount;
                }
              }
            }

            return Row(
              children: [
                Expanded(
                  child: _QuickStatCard(
                    title: 'Today',
                    amount: todayExpense,
                    icon: Icons.today,
                    color: const Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickStatCard(
                    title: 'This Week',
                    amount: weekExpense,
                    icon: Icons.date_range,
                    color: const Color(0xFF4ECDC4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickStatCard(
                    title: 'This Month',
                    amount: monthExpense,
                    icon: Icons.calendar_month,
                    color: const Color(0xFF9B59B6),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Add Expense',
                  color: const Color(0xFFFF4757),
                  onTap: () => Get.to(() => AddTransactionScreen(initialType: 'expense')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.arrow_downward,
                  label: 'Add Income',
                  color: const Color(0xFF2ECC71),
                  onTap: () => Get.to(() => AddTransactionScreen(initialType: 'income')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.list_alt,
                  label: 'All Transactions',
                  color: const Color(0xFF4ECDC4),
                  onTap: () => Get.to(() => TransactionsListScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingOverview(ExpenseController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Spending Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Obx(() {
                const validFilters = ['All', 'Income', 'Expense'];
                final selectedValue = validFilters.contains(_dashboardFilter.value)
                    ? _dashboardFilter.value
                    : 'All';

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButton<String>(
                    value: selectedValue,
                    underline: const SizedBox(),
                    isDense: true,
                    items: validFilters
                        .map((filter) => DropdownMenuItem(
                              value: filter,
                              child: Text(
                                filter,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) _dashboardFilter.value = value;
                    },
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),
          _buildSpendingPie(controller),
        ],
      ),
    );
  }

  Widget _buildSpendingPie(ExpenseController controller) {
    return Obx(() {
      final categoryExpenses = controller.getCategoryData(_dashboardFilter.value);
      if (categoryExpenses.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first transaction to see insights',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      final total = categoryExpenses.values.fold(0.0, (s, v) => s + v);
      if (total <= 0) {
        return Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              'No amounts to display',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        );
      }

      final entries = categoryExpenses.entries.toList();
      entries.sort((a, b) => b.value.compareTo(a.value));

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 60,
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback: (FlTouchEvent event, baseTouchResponse) {},
                  ),
                  sections: entries.map((entry) {
                    final percentage = (entry.value / total) * 100;
                    return PieChartSectionData(
                      value: entry.value,
                      title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                      color: _categoryColorMap[entry.key] ?? Colors.grey,
                      radius: 65,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 800),
                swapAnimationCurve: Curves.easeInOutCubic,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: entries.map((e) {
                final percent = (e.value / total) * 100;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (_categoryColorMap[e.key] ?? Colors.grey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _categoryColorMap[e.key] ?? Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${e.key}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${percent.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRecentTransactionsSection(ExpenseController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => TransactionsListScreen()),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecentTransactionsList(controller),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsList(ExpenseController controller) {
    return Obx(() {
      // Explicitly limit to 5 recent transactions
      final allTransactions = controller.getFilteredTransactions(_dashboardFilter.value);
      final transactions = allTransactions.take(5).toList();
      
      if (transactions.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Start tracking your expenses',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
        );
      }

      // Display transactions (already limited to maximum 5)
      return Column(
        children: transactions.map((transaction) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ModernTransactionCard(
              transaction: transaction,
              categoryColorMap: _categoryColorMap,
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Get.to(() => AddTransactionScreen()),
      backgroundColor: primaryColor,
      elevation: 8,
      icon: const Icon(Icons.add, color: Colors.white, size: 24),
      label: const Text(
        'Add Transaction',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

/// Modern Balance Card Component
class _ModernBalanceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isIncome;

  const _ModernBalanceCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpenseController>();
    return Obx(() {
      final amount = isIncome ? controller.totalIncome : controller.totalExpense;
      final amountText = '₹${amount.toStringAsFixed(2)}';

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              amountText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Quick Stat Card Component
class _QuickStatCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _QuickStatCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${amount.toStringAsFixed(0)}',
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
}

/// Quick Action Button Component
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Transaction Card Component
class _ModernTransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final Map<String, Color> categoryColorMap;

  const _ModernTransactionCard({
    required this.transaction,
    required this.categoryColorMap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ExpenseController>()
        ? Get.find<ExpenseController>()
        : Get.put(ExpenseController());

    final icon = transaction.type == 'income'
        ? controller.incomeCategoryIcons[transaction.category] ?? Icons.more_horiz
        : controller.expenseCategoryIcons[transaction.category] ?? Icons.more_horiz;

    final color = categoryColorMap[transaction.category] ?? Colors.grey;

    return GestureDetector(
      onTap: () => Get.to(() => AddTransactionScreen(transaction: transaction)),
      onLongPress: () => _showDeleteDialog(context: context, controller: controller, tx: transaction),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title ?? 'Untitled',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.category, size: 12, color: Colors.grey.shade600),
                          SizedBox(width: 4),
                          Text(
                            '${transaction.category ?? 'Others'}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                          SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(transaction.date),
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.type == 'expense' ? '-' : '+'}₹${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaction.type == 'expense' ? const Color(0xFFFF4757) : const Color(0xFF2ECC71),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: transaction.type == 'expense'
                        ? const Color(0xFFFF4757).withOpacity(0.1)
                        : const Color(0xFF2ECC71).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.type == 'expense' ? 'Expense' : 'Income',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: transaction.type == 'expense' ? const Color(0xFFFF4757) : const Color(0xFF2ECC71),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog({
    required BuildContext context,
    required ExpenseController controller,
    required TransactionModel tx,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.delete_forever, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Delete Transaction?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tx.title ?? 'Untitled',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      controller.deleteTransaction(tx.id);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Deleted "${tx.title ?? 'Transaction'}"'),
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFF1A1A1A),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.yellowAccent,
            onPressed: () {
              controller.transactions.insert(0, tx);
              controller.saveTransactions();
              Get.snackbar('Restored', 'Transaction restored', snackPosition: SnackPosition.TOP);
            },
          ),
        ),
      );
    }
  }
}
