// lib/screens/edit_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
 
class EditExpenseScreen extends StatefulWidget {
  final Expense expense;   // The expense object to edit
  final int expenseKey;    // The Hive box key for this expense
 
  const EditExpenseScreen({
    super.key,
    required this.expense,
    required this.expenseKey,
  });
 
  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}
 
class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _amountCtrl;
  late ExpenseCategory _category;
  late DateTime _date;
 
  @override
  void initState() {
    super.initState();
    // Pre-fill all fields with the existing expense data
    _titleCtrl  = TextEditingController(text: widget.expense.title);
    _amountCtrl = TextEditingController(
        text: widget.expense.amount.toStringAsFixed(2));
    _category   = widget.expense.category;
    _date       = widget.expense.date;
  }
 
  @override
  void dispose() {
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
      context: context, initialDate: _date,
      firstDate: DateTime(2020), lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }
 
  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    await ExpenseService.updateExpense(
      widget.expenseKey,
      Expense(
        title:    _titleCtrl.text.trim(),
        amount:   double.parse(_amountCtrl.text.trim()),
        category: _category,
        date:     _date,
      ),
    );
    if (mounted) Navigator.pop(context);
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Expense Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Title cannot be empty.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '₱ ',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount cannot be empty.';
                final amt = double.tryParse(v.trim());
                if (amt == null || amt <= 0) return 'Enter a valid positive amount.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExpenseCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: ExpenseCategory.values.map((cat) => DropdownMenuItem(
                value: cat, child: Text(_categoryLabel(cat)),
              )).toList(),
              onChanged: (v) { if (v != null) setState(() => _category = v); },
            ),
            const SizedBox(height: 16),
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
            ElevatedButton.icon(
              onPressed: _update,
              icon: const Icon(Icons.update),
              label: const Text('Update Expense', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52)),
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
          ]),
        ),
      ),
    );
  }
}
