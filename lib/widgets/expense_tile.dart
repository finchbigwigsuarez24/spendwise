// lib/widgets/expense_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
 
class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
 
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onDelete,
    required this.onEdit,
  });
 
  // Map each category to a representative Material icon
  IconData _icon(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.food:          return Icons.restaurant;
      case ExpenseCategory.transport:     return Icons.directions_car;
      case ExpenseCategory.shopping:      return Icons.shopping_bag_outlined;
      case ExpenseCategory.utilities:     return Icons.bolt;
      case ExpenseCategory.entertainment: return Icons.movie_outlined;
      case ExpenseCategory.other:         return Icons.more_horiz;
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // expense.key is the Hive box key — guaranteed unique per expense
      key: ValueKey(expense.key),
      // Allow swipe only from right to left (end-to-start)
      direction: DismissDirection.endToStart,
      // Red delete background revealed when swiping
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      // Show a confirmation dialog before committing the delete
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Expense'),
            content: Text('Delete "${expense.title}"? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.primaryContainer,
            child: Icon(_icon(expense.category),
              color: Theme.of(context).colorScheme.primary),
          ),
          title: Text(expense.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          subtitle: Text(
            '${expense.categoryName}  ·  ${DateFormat('MMM dd, yyyy').format(expense.date)}',
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('₱${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 16, color: Colors.indigo)),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                onPressed: onEdit,
                tooltip: 'Edit expense',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
