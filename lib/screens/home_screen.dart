// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/expense_tile.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';
 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen> {
  // null = show ALL categories; a specific value filters the list
  ExpenseCategory? _selectedCategory;
 
  // Category display name helper
  String _label(ExpenseCategory? cat) {
    if (cat == null) return 'All';
    switch (cat) {
      case ExpenseCategory.food:          return 'Food';
      case ExpenseCategory.transport:     return 'Transport';
      case ExpenseCategory.shopping:      return 'Shopping';
      case ExpenseCategory.utilities:     return 'Utilities';
      case ExpenseCategory.entertainment: return 'Entertainment';
      case ExpenseCategory.other:         return 'Other';
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendWise', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'SpendWise',
              applicationVersion: '1.0.0',
              children: [const Text('A personal expense tracker built with Hive.')],
            ),
          ),
        ],
      ),
      // ValueListenableBuilder listens to the Hive box and rebuilds automatically
      body: ValueListenableBuilder<Box<Expense>>(
        valueListenable: ExpenseService.listenable,
        builder: (context, box, _) {
          // Recalculate every time the box changes
          final double total = box.values.fold(0.0, (s, e) => s + e.amount);
          final List<Expense> expenses = _selectedCategory == null
              ? ExpenseService.getAllExpenses()
              : ExpenseService.getExpensesByCategory(_selectedCategory!);
 
          // Sort by date descending (newest first)
          expenses.sort((a, b) => b.date.compareTo(a.date));
 
          return Column(
            children: [
              _buildSummaryCard(total, box.length),
              _buildFilterChips(),
              Expanded(child: _buildExpenseList(expenses)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
 
  Widget _buildSummaryCard(double total, int count) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total Spending',
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
              Text('$count expense${count == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 12, color: Colors.black45)),
            ]),
            Text(
              '₱${total.toStringAsFixed(2)}', // ₱ symbol
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                color: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildFilterChips() {
    final categories = [null, ...ExpenseCategory.values];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: categories.map((cat) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(_label(cat)),
            selected: _selectedCategory == cat,
            onSelected: (_) => setState(() => _selectedCategory = cat),
          ),
        )).toList(),
      ),
    );
  }
 
  Widget _buildExpenseList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No expenses yet!',
            style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Tap the button below to add your first expense.',
            style: TextStyle(color: Colors.grey[400])),
        ]),
      );
    }
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, i) {
        final expense = expenses[i];
        final int key = expense.key as int;
        return ExpenseTile(
          expense: expense,
          onDelete: () => ExpenseService.deleteExpense(key),
          onEdit: () => Navigator.push(ctx,
            MaterialPageRoute(builder: (_) =>
              EditExpenseScreen(expense: expense, expenseKey: key))),
        );
      },
    );
  }
}