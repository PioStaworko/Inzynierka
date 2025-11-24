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
import 'providers/starting_balance_provider.dart';
import 'providers/savings_goals_provider.dart';

import 'providers/category_provider.dart';

import 'screens/home_screen.dart';
import 'screens/initial_balance_screen.dart';


import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

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
        
        ChangeNotifierProvider(create: (_) => ExpensesState(appDb.expensesDao, appDb.budgetsDao, appDb.categoriesDao)),
        
        ChangeNotifierProvider(create: (_) => IncomeProvider(appDb.incomesDao, appDb.recurringDao)),

        ChangeNotifierProvider(create: (_) => RecurringExpenseProvider(appDb.recurringDao, appDb.categoriesDao)),
        ChangeNotifierProvider(create: (_) => RecurringIncomeProvider(appDb.recurringDao)),
        ChangeNotifierProvider(create: (_) => CategoryProvider(appDb.categoriesDao)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => StartingBalanceProvider()),
        ChangeNotifierProvider(create: (_) => SavingsGoalsProvider(appDb)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
            return _LifecycleHandler(
            child: MaterialApp(
            title: 'Savings App',
            routes: {
              '/home': (ctx) => const MyHomePage(),
              '/initial_balance': (ctx) => const InitialBalanceScreen(),
            },
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
            home: Builder(
              builder: (ctx) {
                final sb = Provider.of<StartingBalanceProvider>(ctx);
                if (!sb.loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
                if (!sb.saved) return const InitialBalanceScreen();
                return const MyHomePage();
              },
            ),
            ),
            onPaused: () {
              // When the app goes to background, process pending budget checks so
              // notifications will be shown after leaving the app.
              try {
                final expenses = Provider.of<ExpensesState>(context, listen: false);
                expenses.processPendingBudgetChecks();
              } catch (_) {}
            },
          );
        },
      ),
    );
  }
}

class _LifecycleHandler extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPaused;
  const _LifecycleHandler({required this.child, this.onPaused});

  @override
  State<_LifecycleHandler> createState() => _LifecycleHandlerState();
}

class _LifecycleHandlerState extends State<_LifecycleHandler> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      widget.onPaused?.call();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}