import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/expense_controller.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';

/// Polished TransactionsListScreen
/// - Search
/// - Segmented filter (All / Income / Expense)
/// - Pull-to-refresh
/// - Swipe-to-delete with UNDO
/// - Grouped by month with neat headers
/// - Modern Material design (rounded cards, elevation, subtle shadows)
class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  final controller = Get.isRegistered<ExpenseController>()
      ? Get.find<ExpenseController>()
      : Get.put(ExpenseController());

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // debounce to avoid heavy rebuilds while typing
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title:  Text('Transactions',style: TextStyle(color: Colors.white),),
        backgroundColor:  Color(0xFF6C63FF),
        elevation: 0,
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _buildSearchField(theme),
                  const SizedBox(height: 12),
                  _buildFilterSegment(),
                ],
              ),
            ),

            // List area
            Expanded(child: Obx(_buildListArea)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddTransactionScreen()),
        backgroundColor: const Color(0xFF6C63FF),
        icon:  Icon(Icons.add,color: Colors.white,),
        label:  Text('Add',style: TextStyle(color: Colors.white),),
      ),
    );
  }
  Widget _buildSearchField(ThemeData theme) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search title, category or amount',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterSegment() {
    return Obx(() {
      final selected = controller.selectedFilter.value;

      // Take around 65% of screen width for a balanced look
      final double totalWidth = MediaQuery.of(context).size.width * 0.65;
      final double perSegmentWidth = (totalWidth - 12) / 3;

      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SizedBox(
          height: 48, // ✅ perfect height for all screens
          width: totalWidth,
          child: SegmentedButton<String>(
            showSelectedIcon: false, // clean, centered look
            segments: [
              ButtonSegment(
                value: 'All',
                label: SizedBox(
                  width: perSegmentWidth,
                  child: const Center(
                    child: Text('All',
                        style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ),
              ButtonSegment(
                value: 'Income',
                label: SizedBox(
                  width: perSegmentWidth,
                  child: const Center(
                    child: Text('Income',
                        style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ),
              ButtonSegment(
                value: 'Expense',
                label: SizedBox(
                  width: perSegmentWidth,
                  child: const Center(
                    child: Text('Expense',
                        style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ),
            ],
            selected: {selected},
            onSelectionChanged: (Set<String> newSelection) {
              if (newSelection.isNotEmpty) {
                controller.selectedFilter.value = newSelection.first;
              }
            },
            style: ButtonStyle(
              padding: const MaterialStatePropertyAll(EdgeInsets.zero),
              visualDensity: VisualDensity.standard,
              textStyle: const MaterialStatePropertyAll(TextStyle(fontSize: 15)),
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const Color(0xFF6C63FF).withOpacity(0.15);
                }
                return Colors.white;
              }),
              foregroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const Color(0xFF6C63FF);
                }
                return Colors.black87;
              }),
              shape: const MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }



  // Replace your existing _buildListArea() with this:

  Widget _buildListArea() {
    final all = controller.filteredTransactions;

    // Apply search locally (title, category, amount)
    final filtered = _applySearch(all, _searchQuery);

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    // Group by 'MMMM yyyy'
    final grouped = <String, List<TransactionModel>>{};
    for (var tx in filtered) {
      final key = DateFormat('MMMM yyyy').format(tx.date);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(tx);
    }

    // sort groups by date desc
    final monthKeys = grouped.keys.toList()
      ..sort((a, b) {
        final da = DateFormat('MMMM yyyy').parse(a);
        final db = DateFormat('MMMM yyyy').parse(b);
        return db.compareTo(da);
      });

    // ensure the ListView has bottom space for keyboard / FAB
    final bottomInset = MediaQuery.of(context).viewInsets.bottom + 88.0;

    return RefreshIndicator(
      onRefresh: () async => controller.loadTransactions(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(12, 8, 12, bottomInset),
        itemCount: monthKeys.length,
        itemBuilder: (context, idx) {
          final month = monthKeys[idx];
          final items = grouped[month]!;

          // Pre-sort transactions within the month (newest first)
          items.sort((a, b) => b.date.compareTo(a.date));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month header with net total and subtle divider
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 14, 6, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      month,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _computeMonthNet(items) < 0 ? Colors.red.withOpacity(0.08) : Colors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatCurrency(items),
                        style: TextStyle(
                          color: _computeMonthNet(items) < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Items: Dismissible + long-press enabled tiles
              Column(
                children: items.map((tx) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _buildDismissibleTileWithLongPress(tx),
                  );
                }).toList(),
              ),

              // small gap after month
              const SizedBox(height: 8),
              const Divider(height: 6, thickness: 0.4),
            ],
          );
        },
      ),
    );
  }

// Add these helper methods inside the same State class:

  /// Shows a confirm dialog; returns true if user confirmed deletion.
  Future<bool> _showConfirmDeleteDialog(TransactionModel tx) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Container(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade700]),
                  ),
                  child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 12),
                const Text('Delete transaction?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(tx.title ?? 'Untitled', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Text('Amount: ${NumberFormat.currency(symbol: "₹").format(tx.amount)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
    return res == true;
  }

  /// Performs delete and shows UNDO snackbar (re-inserts tx if undone)
  void _performDeleteWithUndo(TransactionModel tx) {
    // take a copy for undo restore
    final backup = tx;

    // delete
    controller.deleteTransaction(tx.id);

    // show undo snack
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Deleted \"${tx.title ?? 'Transaction'}\"'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.yellowAccent,
          onPressed: () {
            // restore original transaction at top
            controller.transactions.insert(0, backup);
            controller.saveTransactions();
            Get.snackbar('Restored', 'Transaction restored', snackPosition: SnackPosition.BOTTOM);
          },
        ),
      ),
    );
  }

  /// Dismissible tile that also supports long-press delete via same confirm dialog.
  Widget _buildDismissibleTileWithLongPress(TransactionModel tx) {
    final category = tx.category ?? 'Others';
    final icon = tx.type == 'income'
        ? controller.incomeCategoryIcons[category] ?? Icons.more_horiz
        : controller.expenseCategoryIcons[category] ?? Icons.more_horiz;
    final categoryColor = _categoryColor(category);

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 0),
        padding: const EdgeInsets.only(right: 18),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        // show confirm dialog; if true, allow dismiss to proceed (onDismissed will run)
        return await _showConfirmDeleteDialog(tx);
      },
      onDismissed: (_) {
        // perform actual deletion and show undo snackbar
        _performDeleteWithUndo(tx);
      },
      child: GestureDetector(
        onLongPress: () async {
          final confirm = await _showConfirmDeleteDialog(tx);
          if (confirm) _performDeleteWithUndo(tx);
        },
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onTap: () => Get.to(() => AddTransactionScreen(transaction: tx)),
            leading: _buildLeadingAvatar(tx),
            title: Text(tx.title ?? 'Untitled', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${tx.category ?? 'Others'} • ${DateFormat('MMM dd, yyyy').format(tx.date)}', style: const TextStyle(fontSize: 13)),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${tx.type == 'expense' ? '-' : '+'}${NumberFormat.currency(symbol: '₹').format(tx.amount)}',
                  style: TextStyle(color: tx.type == 'expense' ? Colors.red : Colors.green, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(DateFormat('hh:mm a').format(tx.date), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }



  List<TransactionModel> _applySearch(List<TransactionModel> list, String q) {
    if (q.isEmpty) return list;
    final lower = q.toLowerCase();
    return list.where((t) {
      final title = t.title?.toLowerCase() ?? '';
      final category = t.category?.toLowerCase() ?? '';
      final amount = t.amount.toString();
      return title.contains(lower) || category.contains(lower) || amount.contains(lower);
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Icon(Icons.inbox, size: 96, color: Colors.grey[300]),
            const SizedBox(height: 18),
            Text('No transactions', style: TextStyle(fontSize: 20, color: Colors.grey[700], fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Add your first transaction using the + button below', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  double _computeMonthNet(List<TransactionModel> items) {
    double net = 0;
    for (var t in items) net += (t.type == 'expense' ? -t.amount : t.amount);
    return net;
  }

  String _formatCurrency(List<TransactionModel> items) {
    final net = _computeMonthNet(items);
    final formatted = NumberFormat.currency(symbol: '\$').format(net.abs());
    return (net < 0 ? '-' : '') + formatted;
  }


  Widget _buildLeadingAvatar(TransactionModel tx) {
    final cat = tx.category ?? 'Others';
    final color = _categoryColor(cat);

    final icon = tx.type == 'income'
        ? controller.incomeCategoryIcons[cat] ?? Icons.monetization_on
        : controller.expenseCategoryIcons[cat] ?? Icons.more_horiz;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Color _categoryColor(String category) {
    const map = {
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
    return map[category] ?? Colors.grey;
  }

}
