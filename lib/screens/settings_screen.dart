import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia')),
      body: ListView(
        children: [
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
          const Divider(),
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