// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // <--- DODAJ IMPORT (dla formatowania daty)

import '../providers/expenses_provider.dart';
import '../providers/income_provider.dart'; // <--- DODAJ IMPORT
import '../widgets/pie_chart_widget.dart';
import '../screens/add_expense_screen.dart';
import '../screens/add_income_screen.dart';
import '../screens/add_recurring_expense_screen.dart'; // <--- DODAJ IMPORT
import '../widgets/app_drawer.dart'; // <-- Nasz nowy widżet szuflady

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  // Mapa kolorów pozostaje bez zmian
  static const Map<String, Color> categoryColors = {
    'Food': Colors.deepOrange,
    'Transport': Colors.blue,
    'Entertainment': Colors.purple,
    'Other': Colors.green,
  };

  // Funkcja modalna musi być teraz wewnątrz klasy,
  // aby mogła być wywołana z `floatingActionButton`
  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.remove),
                title: const Text('Dodaj wydatek'),
                onTap: () {
                  Navigator.of(ctx).pop(); // Zamknij modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddExpenseScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Dodaj przychód'),
                onTap: () {
                  Navigator.of(ctx).pop(); // Zamknij modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddIncomeScreen(),
                    ),
                  );
                },
              ),
              // <--- DODANA OPCJA WYDATKU CYKLICZNEGO (z poprzedniego kroku)
              ListTile(
                leading: const Icon(Icons.replay), // Ikona "powtarzania"
                title: const Text('Dodaj wydatek cykliczny'),
                onTap: () {
                  Navigator.of(ctx).pop(); // Zamknij modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddRecurringExpenseScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // === ZMIANA: Pobieramy OBA providery ===
    final expenseState = context.watch<ExpensesState>();
    final incomeState = context.watch<IncomeProvider>();

    // === ZMIANA: Obliczenia salda ===
    final totals = expenseState.totalsByCategory;
    final totalExpenses = totals.values.fold(0.0, (sum, item) => sum + item);
    final totalIncomes = incomeState.totalIncome;
    final balance = totalIncomes - totalExpenses;
    // ======================================

    return Scaffold(
      appBar: AppBar(title: const Text('Mój Budżet')), // Zmieniony tytuł
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // <--- POCZĄTEK: NOWA KARTA SALDA (Krok 8) ===
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      const Text('SALDO',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        '${balance.toStringAsFixed(2)} zł',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: balance >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Przychody: ${totalIncomes.toStringAsFixed(2)} zł',
                              style: const TextStyle(color: Colors.green)),
                          Text('Wydatki: ${totalExpenses.toStringAsFixed(2)} zł',
                              style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // <--- KONIEC: NOWA KARTA SALDA ===

            // Karta wykresu (bez zmian)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
                child: Column(
                  children: [
                    const Text('Koszty według kategorii',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: PieChartWidget(
                          data: totals,
                          colors: MyHomePage.categoryColors,
                          size: 160,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: totals.keys.map((k) {
                        final c = categoryColors[k] ?? Colors.grey;
                        return Chip(
                          avatar: CircleAvatar(backgroundColor: c),
                          label: Text('$k — ${totals[k]!.toStringAsFixed(2)} zł'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Karta listy wydatków (poprawka formatowania daty)
            Expanded(
              child: Card(
                child: Column(
                  children: [
                    const ListTile(
                      title: Text('Ostatnie wydatki',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const Divider(height: 0),
                    Expanded(
                      child: ListView.separated(
                        // Używamy `expenseState` zamiast `state`
                        itemCount: expenseState.recent.length,
                        separatorBuilder: (_, __) => const Divider(height: 0),
                        itemBuilder: (context, index) {
                          final e = expenseState.recent[index];
                          final color = categoryColors[e.category] ?? Colors.grey;

                          // === NOWY KOD: Widżet Dismissible ===
                          return Dismissible(
                            key: ValueKey(e.id), // Klucz jest niezbędny! Używamy ID z bazy.
                            direction: DismissDirection.endToStart, // Przesuwanie tylko w lewo
                            background: Container(
                              color: Colors.red.shade700,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              // Wywołujemy usuwanie z providera
                              context.read<ExpensesState>().deleteExpense(e.id);

                              // Pokaż potwierdzenie
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Usunięto "${e.title}"'),
                                  action: SnackBarAction(label: 'COFNIJ', onPressed: () {
                                    // TODO: Cofanie usunięcia (bardziej zaawansowane)
                                  }),
                                ),
                              );
                            },
                            child: ListTile( // <--- Nasz stary ListTile jest teraz 'dzieckiem'
                              leading: CircleAvatar(
                                  backgroundColor: color,
                                  child: Text(e.category[0])),
                              title: Text(e.title),
                              subtitle: Text(
                                  '${DateFormat('dd.MM.yyyy').format(e.date)} • ${e.category}'),
                              trailing: Text('${e.amount.toStringAsFixed(2)} zł',
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          );
                          // ===================================
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wywołujemy funkcję zdefiniowaną w klasie
          _showAddOptions(context);

        },
        child: const Icon(Icons.add),
      ),
    );
  }
}