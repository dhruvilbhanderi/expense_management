import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class ExpenseController extends GetxController {
  var transactions = <TransactionModel>[].obs;
  var selectedFilter = 'All'.obs;
  var selectedMonth = DateTime.now().obs;

  final Map<String, IconData> expenseCategoryIcons = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt,
    'Health': Icons.local_hospital,
    'Education': Icons.school,
    'Others': Icons.more_horiz,
  };

  final Map<String, IconData> incomeCategoryIcons = {
    'Salary': Icons.work,
    'Business': Icons.store,
    'Investments': Icons.trending_up,
    'Freelance': Icons.laptop_mac,
    'Gift': Icons.card_giftcard,
    'Others': Icons.more_horiz,
  };

  final List<String> expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
    'Education',
    'Others'
  ];

  final List<String> incomeCategories = [
    'Salary',
    'Business',
    'Investments',
    'Freelance',
    'Gift',
    'Others'
  ];

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  double get totalIncome =>
      transactions.where((t) => t.type == 'income').fold(0, (a, t) => a + t.amount);

  double get totalExpense =>
      transactions.where((t) => t.type == 'expense').fold(0, (a, t) => a + t.amount);

  double get balance => totalIncome - totalExpense;

  List<TransactionModel> get filteredTransactions {
    var filtered = transactions.where((t) {
      if (selectedFilter.value == 'All') return true;
      return t.type == selectedFilter.value.toLowerCase();
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('transactions');
    if (data != null) {
      final List<dynamic> jsonList = json.decode(data);
      transactions.value =
          jsonList.map((json) => TransactionModel.fromJson(json)).toList();
    }
  }

  Future<void> saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String data =
    json.encode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString('transactions', data);
  }

  void addTransaction(TransactionModel transaction) {
    transactions.add(transaction);
    saveTransactions();
    Get.back();
    Get.snackbar(
      'Success',
      'Transaction added successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void updateTransaction(TransactionModel transaction) {
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      saveTransactions();
      Get.back();
      Get.snackbar(
        'Success',
        'Transaction updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }

  void deleteTransaction(String id) {
    transactions.removeWhere((t) => t.id == id);
    saveTransactions();
    Get.snackbar(
      'Success',
      'Transaction deleted successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Map<String, double> getCategoryExpenses() {
    Map<String, double> categoryData = {};
    for (var transaction in transactions.where((t) => t.type == 'expense')) {
      categoryData[transaction.category] =
          (categoryData[transaction.category] ?? 0) + transaction.amount;
    }
    return categoryData;
  }
}