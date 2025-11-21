// lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/recurring_expenses_list_screen.dart'; // Stworzymy ten plik za chwilę
import '../screens/recurring_income_list_screen.dart';
import '../screens/settings_screen.dart';
import '../providers/theme_provider.dart';
import '../screens/budgets_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Nagłówek szuflady
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepOrange,
            ),
            child: Text(
              'Menu Główne',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // Opcja 1: Powrót do pulpitu
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Mój Budżet (Pulpit)'),
            onTap: () {
              // Po prostu zamknij szufladę, bo już tam jesteśmy
              Navigator.of(context).pop();
            },
          ),
          // Opcja 2: Nasz nowy ekran
          ListTile(
            leading: const Icon(Icons.replay),
            title: const Text('Wydatki Cykliczne'),
            onTap: () {
              // 1. Zamknij szufladę
              Navigator.of(context).pop();
              // 2. Przejdź do nowego ekranu
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => const RecurringExpensesListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.replay),
            title: const Text('Przychody Stałe'),
            onTap: () {
              // 1. Zamknij szufladę
              Navigator.of(context).pop();
              // 2. Przejdź do nowego ekranu
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => const RecurringIncomeListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.pie_chart), 
            title: const Text('Budżety i Cele'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const BudgetScreen()), 
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ustawienia'),
            onTap: () {
              // 1. Zamknij szufladę
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
              );
            },
          ),
          // Motyw - szybkie przełączanie (System / Jasny / Ciemny)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                final current = themeProvider.themeMode;
                return ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Motyw'),
                  trailing: DropdownButton<ThemeMode>(
                    value: current,
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('Systemowy')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Jasny')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Ciemny')),
                    ],
                    onChanged: (v) {
                      if (v != null) themeProvider.setThemeMode(v);
                    },
                  ),
                );
              },
            ),
          ),
          // Tutaj w przyszłości możesz dodać "Przychody", "Ustawienia" itp.
        ],
      ),
    );
  }
}