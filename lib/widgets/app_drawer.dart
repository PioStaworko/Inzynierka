// lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import '../screens/recurring_expenses_list_screen.dart'; // Stworzymy ten plik za chwilę

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
          // Tutaj w przyszłości możesz dodać "Przychody", "Ustawienia" itp.
        ],
      ),
    );
  }
}