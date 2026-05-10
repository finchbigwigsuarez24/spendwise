// lib/services/expense_service.dart
import 'package:flutter/foundation.dart'; // For ValueListenable
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
 
// ExpenseService wraps all Hive box operations in one place.
// This keeps Hive-specific code OUT of the UI widgets — good architecture!
class ExpenseService {
  // The box name must match the name used in Hive.openBox() in main.dart
  static const String _boxName = 'expenses';
 
  // Private getter — retrieves the already-open typed box
  // We use a getter (not a field) so it always returns the current box reference
  static Box<Expense> get _box => Hive.box<Expense>(_boxName);
 
  // ── CREATE ─────────────────────────────────────────────────────────────
  // box.add() stores the expense and auto-assigns an integer key
  // Returns a Future<int> (the new key), but we ignore it here
  static Future<void> addExpense(Expense expense) async {
    await _box.add(expense);
  }
 
  // ── READ (ALL) ─────────────────────────────────────────────────────────
  // box.values returns an Iterable — we convert it to a List for easy use
  // The list is returned in insertion order (oldest first by default)
  static List<Expense> getAllExpenses() {
    return _box.values.toList();
  }
 
  // ── READ (FILTERED BY CATEGORY) ────────────────────────────────────────
  // Uses Dart's where() to filter — no Hive-specific query language needed
  static List<Expense> getExpensesByCategory(ExpenseCategory category) {
    return _box.values
        .where((expense) => expense.category == category)
        .toList();
  }
 
  // ── UPDATE ─────────────────────────────────────────────────────────────
  // box.put(key, value) replaces the value stored at the given key
  // 'key' is the integer key assigned by box.add() when the expense was created
  static Future<void> updateExpense(int key, Expense updated) async {
    await _box.put(key, updated);
  }
 
  // ── DELETE ─────────────────────────────────────────────────────────────
  // box.delete(key) removes the entry entirely from the box
  static Future<void> deleteExpense(int key) async {
    await _box.delete(key);
  }
 
  // ── REACTIVE UPDATES ───────────────────────────────────────────────────
  // listenable() returns a ValueListenable that notifies listeners whenever
  // ANY change (add, update, delete) happens to the box.
  // Pass this to ValueListenableBuilder in your widgets to get auto-rebuilds.
  static ValueListenable<Box<Expense>> get listenable =>
      _box.listenable();
 
  // ── HELPERS ────────────────────────────────────────────────────────────
  // Calculates the sum of all expense amounts in the box
  static double getTotalExpenses() {
    return _box.values.fold(0.0, (sum, e) => sum + e.amount);
  }
 
  // Get total for a specific month (year + month combination)
  static double getMonthlyTotal(int year, int month) {
    return _box.values
        .where((e) => e.date.year == year && e.date.month == month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}
