import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  final String? initialType;

  const AddTransactionScreen({Key? key, this.transaction, this.initialType}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.isRegistered<ExpenseController>()
      ? Get.find<ExpenseController>()
      : Get.put(ExpenseController());

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.transaction?.title);
    _amountController =
        TextEditingController(text: widget.transaction?.amount.toString());
    _noteController = TextEditingController(text: widget.transaction?.note);

    _selectedType = widget.transaction?.type ?? widget.initialType ?? 'expense';
    _selectedDate = widget.transaction?.date ?? DateTime.now();

    // ✅ Check category validity before assigning
    if (_selectedType == 'income') {
      if (controller.incomeCategories.contains(widget.transaction?.category)) {
        _selectedCategory = widget.transaction!.category;
      } else {
        _selectedCategory = controller.incomeCategories.first;
      }
    } else {
      if (controller.expenseCategories.contains(widget.transaction?.category)) {
        _selectedCategory = widget.transaction!.category;
      } else {
        _selectedCategory = controller.expenseCategories.first;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<String> get currentCategories =>
      _selectedType == 'income' ? controller.incomeCategories : controller.expenseCategories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
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
            color: const Color(0xFF6C63FF),
            onPressed: () => Get.back(),
          ),
        ),
        title: Text(
          widget.transaction == null ? 'Add Transaction' : 'Edit Transaction',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            // Modern Type Toggle
            _buildTypeToggle(),
            const SizedBox(height: 24),

            // Title Field
            _buildModernTextField(
              controller: _titleController,
              label: 'Title',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount Field
            _buildModernTextField(
              controller: _amountController,
              label: 'Amount',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            _buildCategoryDropdown(),
            const SizedBox(height: 16),

            // Date Picker
            _buildDatePicker(),
            const SizedBox(height: 16),

            // Note Field
            _buildNoteField(),
            const SizedBox(height: 32),

            // Save Button
            _buildSaveButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
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
          Expanded(
            child: _buildToggleOption(
              'Expense',
              Icons.arrow_upward,
              _selectedType == 'expense',
              const Color(0xFFFF4757),
              () => setState(() {
                _selectedType = 'expense';
                _selectedCategory = controller.expenseCategories.first;
              }),
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              'Income',
              Icons.arrow_downward,
              _selectedType == 'income',
              const Color(0xFF2ECC71),
              () => setState(() {
                _selectedType = 'income';
                _selectedCategory = controller.incomeCategories.first;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    String label,
    IconData icon,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
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
      child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
          labelText: _selectedType == 'income' ? 'Income Category' : 'Expense Category',
          prefixIcon: const Icon(Icons.category, color: Color(0xFF6C63FF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              items: (_selectedType == 'income'
                  ? controller.incomeCategories
                  : controller.expenseCategories)
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                      _selectedType == 'income'
                          ? controller.incomeCategoryIcons[category]
                          : controller.expenseCategoryIcons[category],
                          size: 18,
                          color: _getCategoryColor(category),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF6C63FF),
                ),
              ),
              child: child!,
            );
          },
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            const Icon(Icons.calendar_today, color: Color(0xFF6C63FF)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
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
      child: TextFormField(
              controller: _noteController,
        maxLines: 3,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
              decoration: InputDecoration(
                labelText: 'Note (Optional)',
          prefixIcon: const Icon(Icons.note, color: Color(0xFF6C63FF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final isExpense = _selectedType == 'expense';
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isExpense ? const Color(0xFFFF4757) : const Color(0xFF2ECC71),
            isExpense ? const Color(0xFFFF3838) : const Color(0xFF27AE60),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isExpense ? const Color(0xFFFF4757) : const Color(0xFF2ECC71))
                .withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final transaction = TransactionModel(
                      id: widget.transaction?.id ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text,
                      amount: double.parse(_amountController.text),
                      category: _selectedCategory,
                      type: _selectedType,
                      date: _selectedDate,
              note: _noteController.text.isEmpty ? null : _noteController.text,
                    );

                    if (widget.transaction == null) {
                      controller.addTransaction(transaction);
                    } else {
                      controller.updateTransaction(transaction);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              widget.transaction == null ? 'Add Transaction' : 'Update Transaction',
              style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    const map = {
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
    return map[category] ?? Colors.grey;
  }
}
