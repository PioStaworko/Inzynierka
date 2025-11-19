// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Tryb ciemny'),
            subtitle: const Text('Włącz ciemny motyw aplikacji'),
            value: isDark,
            onChanged: (value) {
              context.read<ThemeProvider>().toggleTheme(value);
            },
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          ),
          const Divider(),
          // Miejsce na przyszłe opcje, np. reset danych
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Wyczyść wszystkie dane', style: TextStyle(color: Colors.red)),
            onTap: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Jesteś pewien?'),
        content: const Text('Ta operacja usunie trwale WSZYSTKIE Twoje wydatki i przychody. Tego nie można cofnąć.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Anuluj')),
          TextButton(
            onPressed: () async {
              // Tu logika czyszczenia - możesz ją zaimplementować później
              // Wymagałoby to dodania metody clearAll() w każdym providerze
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funkcja czyszczenia w przygotowaniu')));
            },
            child: const Text('Usuń', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}