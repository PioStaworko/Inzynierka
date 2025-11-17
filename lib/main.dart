// lib/main.dart

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'models/expense_model.dart';
import 'models/income_model.dart'; // Import nowego modelu
import 'models/recurring_expense_model.dart';
import 'providers/expenses_provider.dart';
import 'providers/income_provider.dart';
import 'providers/recurring_expense_provider.dart'; // Import nowego providera
import 'screens/home_screen.dart';

// main() musi być teraz asynchroniczne, aby poczekać na otwarcie bazy
void main() async {
  // Musimy to dodać, aby móc wywoływać kod natywny przed runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Otwieramy instancję Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [ExpenseSchema, 
  IncomeSchema,
  RecurringExpenseSchema], 
  directory: dir.path
  );

  runApp(MyApp(isar: isar)); // Przekazujemy instancję bazy do aplikacji
}

class MyApp extends StatelessWidget {
  // Przechowujemy instancję Isar
  final Isar isar;

  const MyApp({
    super.key,
    required this.isar,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // <--- Używamy MultiProvider
      providers: [
        ChangeNotifierProvider(create: (_) => ExpensesState(isar)),
        ChangeNotifierProvider(create: (_) => IncomeProvider(isar)),
        ChangeNotifierProvider(create: (_) => RecurringExpenseProvider(isar)), // <-- Nowy provider
      ],
      child: MaterialApp(
        title: 'Savings App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}