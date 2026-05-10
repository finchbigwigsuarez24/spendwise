// lib/models/expense.dart
import 'package:hive/hive.dart';
 
// The 'part' directive links this file to its generated counterpart.
// The file expense.g.dart does not exist yet — build_runner will create it.
part 'expense.g.dart';
 
// ── Expense Category Enum ──────────────────────────────────────────────────
// @HiveType registers this enum with Hive. typeId MUST be unique across
// the entire project. We use typeId: 0 for ExpenseCategory.
@HiveType(typeId: 0)
enum ExpenseCategory {
  @HiveField(0) food,          // ₱ spent on meals, snacks, groceries
  @HiveField(1) transport,     // ₱ spent on Grab, jeep, tricycle, bus
  @HiveField(2) shopping,      // ₱ spent on clothing, supplies, gadgets
  @HiveField(3) utilities,     // ₱ spent on load, WiFi, electricity
  @HiveField(4) entertainment, // ₱ spent on streaming, movies, events
  @HiveField(5) other,         // Everything else
}
 
// ── Expense Class ──────────────────────────────────────────────────────────
// @HiveType registers this class with Hive. typeId: 1 (different from the enum).
// Extending HiveObject gives each stored instance access to its own key
// and provides a .save() and .delete() shortcut.
@HiveType(typeId: 1)
class Expense extends HiveObject {
  // Each @HiveField has a unique integer ID (0, 1, 2, 3...).
  // ⚠️ IMPORTANT: Once you have stored data, NEVER change these field IDs.
  // Changing a field ID would cause Hive to read the wrong value for that field.
 
  @HiveField(0)
  late String title; // e.g., "Jollibee Lunch", "Grab Ride to School"
 
  @HiveField(1)
  late double amount; // e.g., 120.50 (always store in Philippine Peso)
 
  @HiveField(2)
  late ExpenseCategory category; // Which category this expense belongs to
 
  @HiveField(3)
  late DateTime date; // The date the expense was incurred
 
  // Constructor — used when creating new Expense objects in the app
  Expense({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });
 
  // Helper getter — returns a human-readable name for the category.
  // This is NOT stored in Hive (no @HiveField annotation).
  String get categoryName {
    switch (category) {
      case ExpenseCategory.food:          return 'Food';
      case ExpenseCategory.transport:     return 'Transport';
      case ExpenseCategory.shopping:      return 'Shopping';
      case ExpenseCategory.utilities:     return 'Utilities';
      case ExpenseCategory.entertainment: return 'Entertainment';
      case ExpenseCategory.other:         return 'Other';
    }
  }
}
