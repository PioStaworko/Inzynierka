// lib/main.dart

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'models/expense_model.dart';
import 'models/income_model.dart';
import 'models/recurring_expense_model.dart';
import 'models/recurring_income_model.dart'; 
import 'models/category_model.dart';
import 'models/product_mapping_model.dart';

import 'providers/expenses_provider.dart';
import 'providers/income_provider.dart';
import 'providers/recurring_expense_provider.dart';
import 'providers/recurring_income_provider.dart'; 
import 'providers/theme_provider.dart';
import 'providers/category_provider.dart';

import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      ExpenseSchema,
      IncomeSchema,
      RecurringExpenseSchema,
      RecurringIncomeSchema,
      CategorySchema,
      ProductMappingSchema
    ],
    directory: dir.path,
  );

  runApp(MyApp(isar: isar));
}

class MyApp extends StatelessWidget {
  final Isar isar;

  const MyApp({super.key, required this.isar});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpensesState(isar)),
        ChangeNotifierProvider(create: (_) => IncomeProvider(isar)),
        ChangeNotifierProvider(create: (_) => RecurringExpenseProvider(isar)),
        ChangeNotifierProvider(create: (_) => RecurringIncomeProvider(isar)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider(isar)),
      ],
      // 4. UŻYJ CONSUMER, ABY NASŁUCHIWAĆ ZMIAN MOTYWU:
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Savings App',
            
            // Konfiguracja jasnego motywu
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 1, 114, 44),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            
            // Konfiguracja ciemnego motywu
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 1, 114, 44),
                brightness: Brightness.dark, // To kluczowa różnica
              ),
              useMaterial3: true,
            ),
            
            // To mówi aplikacji, którego użyć
            themeMode: themeProvider.themeMode, 
            
            home: const MyHomePage(),
          );
        },
      ),
    );
  }
}