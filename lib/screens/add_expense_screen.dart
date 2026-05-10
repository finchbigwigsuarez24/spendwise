// lib/screens/add_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
 
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}
 
class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.food;
  DateTime _date = DateTime.now();
 
  @override
  void dispose() {
    // ALWAYS dispose controllers to prevent memory leaks
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }
 
  String _categoryLabel(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.food:          return 'Food';
      case ExpenseCategory.transport:     return 'Transport';
      case ExpenseCategory.shopping:      return 'Shopping';
      case ExpenseCategory.utilities:     return 'Utilities';
      case ExpenseCategory.entertainment: return 'Entertainment';
      case ExpenseCategory.other:         return 'Other';
    }
  }
 
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }
 
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ExpenseService.addExpense(Expense(
      title:    _titleCtrl.text.trim(),
      amount:   double.parse(_amountCtrl.text.trim()),
      category: _category,
      date:     _date,
    ));
    if (mounted) Navigator.pop(context); // Go back to HomeScreen
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            // Expense Title
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Expense Title',
                hintText: 'e.g., Jollibee Lunch, Grab Ride to School',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Title cannot be empty.' : null,
            ),
            const SizedBox(height: 16),
            // Amount
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'e.g., 120.50',
                border: OutlineInputBorder(),
                prefixText: '₱ ', // ₱
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount cannot be empty.';
                final amt = double.tryParse(v.trim());
                if (amt == null || amt <= 0) return 'Enter a valid positive amount.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Category Dropdown
            DropdownButtonFormField<ExpenseCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: ExpenseCategory.values.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(_categoryLabel(cat)),
              )).toList(),
              onChanged: (v) { if (v != null) setState(() => _category = v); },
            ),
            const SizedBox(height: 16),
            // Date Picker Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.calendar_today, color: Colors.indigo),
                    const SizedBox(width: 12),
                    Text(DateFormat('MMM dd, yyyy').format(_date),
                      style: const TextStyle(fontSize: 16)),
                  ]),
                  TextButton(onPressed: _pickDate, child: const Text('Change')),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Save Button
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Expense', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
