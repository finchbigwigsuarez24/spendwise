// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/expense_tile.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';
import '../services/export_service.dart';

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

  // ── Budget helpers ────────────────────────────────────────────────────────

  /// Read the saved monthly budget (defaults to 0 if never set).
  double get _monthlyBudget {
    final settingsBox = Hive.box('settings');
    return (settingsBox.get('monthly_budget') ?? 0.0) as double;
  }

  /// Show a dialog that lets the user type a new budget amount.
  void _showBudgetDialog() {
    final controller = TextEditingController(
      text: _monthlyBudget > 0 ? _monthlyBudget.toStringAsFixed(2) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Budget amount (₱)',
            prefixText: '₱ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = double.tryParse(controller.text.trim());
              if (value != null && value >= 0) {
                final settingsBox = Hive.box('settings');
                await settingsBox.put('monthly_budget', value);
                if (mounted) setState(() {}); // refresh summary card
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Show a SnackBar warning once the spent percentage hits 80 %+.
  void _maybShowBudgetAlert(double percentage, double budget) {
    if (percentage >= 0.8 && budget > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            '⚠️ Budget Alert: You\'ve used '
            '${(percentage * 100).toStringAsFixed(0)}% '
            'of your monthly budget!',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ));
      });
    }
  }

    //wapa
    Future<void> _exportData() async {
    try {
      final filePath = await ExportService.exportCurrentMonth();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = e is StateError
            ? e.message
            : 'Export failed: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendWise',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Budget button
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Set Monthly Budget',
            onPressed: _showBudgetDialog,
          ),
          //wapa
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _exportData,
            tooltip: 'Export Monthly Report',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'SpendWise',
              applicationVersion: '1.0.0',
              children: [
                const Text('A personal expense tracker built with Hive.')
              ],
            ),
          ),
        ],
      ),
      // ValueListenableBuilder listens to the Hive box and rebuilds automatically
      body: ValueListenableBuilder<Box<Expense>>(
        valueListenable: ExpenseService.listenable,
        builder: (context, box, _) {
          // Recalculate every time the box changes
          final double total =
              box.values.fold(0.0, (s, e) => s + e.amount);
          final List<Expense> expenses = _selectedCategory == null
              ? ExpenseService.getAllExpenses()
              : ExpenseService.getExpensesByCategory(_selectedCategory!);

          // Sort by date descending (newest first)
          expenses.sort((a, b) => b.date.compareTo(a.date));

          // Budget calculations
          final double budget = _monthlyBudget;
          final double percentage =
              budget > 0 ? (total / budget).clamp(0.0, 1.0) : 0.0;

          // Fire alert if needed (after frame)
          _maybShowBudgetAlert(percentage, budget);

          return Column(
            children: [
              _buildSummaryCard(total, box.length),
              if (budget > 0) _buildBudgetBar(total, budget, percentage),
              _buildFilterChips(),
              Expanded(child: _buildExpenseList(expenses)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildSummaryCard(double total, int count) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Spending',
                      style: TextStyle(
                          fontSize: 14, color: Colors.black54)),
                  Text('$count expense${count == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black45)),
                ]),
            Text(
              '₱${total.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }

  /// Progress bar card shown only when a budget has been set.
  Widget _buildBudgetBar(
      double totalSpent, double budget, double percentage) {
    final bool isWarning = percentage >= 0.8;
    final Color barColor = isWarning ? Colors.red : Colors.indigo;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Budget',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700]),
                ),
                GestureDetector(
                  onTap: _showBudgetDialog,
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.indigo,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                color: barColor,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₱${totalSpent.toStringAsFixed(2)} spent',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '₱${budget.toStringAsFixed(2)} budget  •  '
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 12,
                      color: isWarning ? Colors.red : Colors.grey[600],
                      fontWeight: isWarning
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
              ],
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
        children: categories
            .map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_label(cat)),
                    selected: _selectedCategory == cat,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildExpenseList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('No expenses yet!',
                  style: TextStyle(
                      fontSize: 18, color: Colors.grey[600])),
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
          onEdit: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) => EditExpenseScreen(
                      expense: expense, expenseKey: key))),
        );
      },
    );
  }
}