// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import bazy danych
import 'data/app_database.dart';

// Import Providerów
import 'providers/expenses_provider.dart';
import 'providers/income_provider.dart';
import 'providers/recurring_expense_provider.dart';
import 'providers/recurring_income_provider.dart'; 
import 'providers/theme_provider.dart';
import 'providers/category_provider.dart';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja bazy Drift
  final db = AppDb();

  runApp(MyApp(appDb: db));
}

class MyApp extends StatelessWidget {
  final AppDb appDb;

  const MyApp({super.key, required this.appDb});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Udostępniamy bazę danych
        Provider<AppDb>.value(value: appDb),
        
        // Providery otrzymują odpowiednie DAO
        ChangeNotifierProvider(create: (_) => ExpensesState(appDb.expensesDao)),
        
        // IncomeProvider potrzebuje dwóch DAO
        ChangeNotifierProvider(create: (_) => IncomeProvider(appDb.incomesDao, appDb.recurringDao)),
        
        // Reszta providerów (musisz je dostosować analogicznie do IncomeProvider)
        ChangeNotifierProvider(create: (_) => RecurringExpenseProvider(appDb.recurringDao)),
        ChangeNotifierProvider(create: (_) => RecurringIncomeProvider(appDb.recurringDao)),
        ChangeNotifierProvider(create: (_) => CategoryProvider(appDb.categoriesDao)),
        
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Savings App',
            // Primary color/seed for the app - use dark green
            theme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF01743E)),
            ).copyWith(
              // keep some Material defaults but tune AppBar
              appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF01743E)),
            ),
            darkTheme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF01743E), brightness: Brightness.dark),
            ).copyWith(
              appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF01743E)),
            ),
            themeMode: themeProvider.themeMode,
            home: const MyHomePage(),
          );
        },
      ),
    );
  }
}