// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Provides Hive.initFlutter()
import 'models/expense.dart';                     // Our custom data model
import 'screens/home_screen.dart';
 
void main() async 
{
  // STEP 1: Ensure Flutter engine is ready before using platform channels
  // This is required when calling async code before runApp()
  WidgetsFlutterBinding.ensureInitialized();
 
  // STEP 2: Initialise Hive and tell it where to store data on the device
  // hive_flutter uses path_provider internally to find the correct directory
  await Hive.initFlutter();
 
  // STEP 3: Register TypeAdapters BEFORE opening any boxes
  // The adapter for ExpenseCategory (typeId: 0) must come first because
  // the ExpenseAdapter (typeId: 1) references ExpenseCategory during reads
  Hive.registerAdapter(ExpenseCategoryAdapter()); // typeId: 0
  Hive.registerAdapter(ExpenseAdapter());          // typeId: 1
 
  // STEP 4: Open the boxes we will use throughout the app
  // 'expenses' is a typed box — only Expense objects are stored here
  await Hive.openBox<Expense>('expenses');
  // 'settings' is an untyped box — used for the budget value (Exercise 2)
  await Hive.openBox('settings');
 
  // STEP 5: Launch the Flutter app
  runApp(const SpendWiseApp());
}
 
class SpendWiseApp extends StatelessWidget 
{
  const SpendWiseApp({super.key});
 
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: 'SpendWise',
      debugShowCheckedModeBanner: false, // Hides the DEBUG ribbon in the top-right corner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

