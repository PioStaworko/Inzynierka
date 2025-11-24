// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/expenses_provider.dart';
import '../providers/income_provider.dart';
import '../providers/category_provider.dart'; // provider kategorii
import '../providers/starting_balance_provider.dart';
import '../data/app_database.dart';

import '../widgets/pie_chart_widget.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/app_drawer.dart';

import '../screens/add_expense_screen.dart';
import '../screens/add_income_screen.dart';
import '../screens/add_recurring_expense_screen.dart';
import '../screens/add_recurring_income_screen.dart';
import '../screens/scan_receipt_screen.dart';

enum TimeRange { all, year, month, week, day }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TimeRange _selectedRange = TimeRange.all;

  DateTime? _rangeStart(TimeRange range) {
    final now = DateTime.now();
    switch (range) {
      case TimeRange.all:
        return null;
      case TimeRange.year:
        return DateTime(now.year - 1, now.month, now.day);
      case TimeRange.month:
        return DateTime(now.year, now.month - 1, now.day);
      case TimeRange.week:
        return now.subtract(const Duration(days: 7));
      case TimeRange.day:
        return now.subtract(const Duration(days: 1));
    }
  }

  Map<String, double> _computeTotalsForRange(ExpensesState expenseState, TimeRange range, [CategoryProvider? categoryProvider]) {
    final start = _rangeStart(range);
    final map = <String, double>{};

    // expenseState.recent zawiera ExpenseWithItems (nagłówek + lista pozycji)
    for (final entry in expenseState.recent) {
      final exp = entry.expense;
      if (start != null && exp.date.isBefore(start)) continue;

      if (entry.items.isNotEmpty) {
        for (final item in entry.items) {
          final cat = item.categoryId != null ? (categoryProvider?.getNameForId(item.categoryId) ?? 'Inne') : 'Inne';
          map[cat] = (map[cat] ?? 0) + item.amount;
        }
      } else {
        final cat = exp.categoryId != null ? (categoryProvider?.getNameForId(exp.categoryId) ?? 'Inne') : 'Inne';
        map[cat] = (map[cat] ?? 0) + exp.amount;
      }
    }
    return map;
  }

  // <--- ZMIANA: USUNIĘTO static const categoryColors.
  // Nie potrzebujemy już sztywnej mapy, bo kolory są w bazie danych.

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
                leading: const Icon(Icons.document_scanner, color: Colors.blue), // Ikona skanera
                title: const Text('Skanuj Paragon (OCR)'),
                subtitle: const Text('Automatyczne dodawanie pozycji'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanReceiptScreen()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.remove, color: Colors.red),
                title: const Text('Dodaj wydatek'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.green),
                title: const Text('Dodaj przychód'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddIncomeScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.replay, color: Colors.red),
                title: const Text('Dodaj wydatek cykliczny'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecurringExpenseScreen()));
                },
              ),
               ListTile(
                leading: const Icon(Icons.replay, color: Colors.green),
                title: const Text('Dodaj przychód cykliczny'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecurringIncomeScreen()));
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
    final expenseState = context.watch<ExpensesState>();
    final incomeState = context.watch<IncomeProvider>();
    // <--- ZMIANA: Pobieramy CategoryProvider, aby mieć dostęp do kolorów
    final categoryProvider = context.watch<CategoryProvider>(); 

    final totals = _computeTotalsForRange(expenseState, _selectedRange, categoryProvider);
    final totalExpenses = totals.values.fold(0.0, (sum, item) => sum + item);
    final totalIncomes = incomeState.totalIncome;
    final starting = context.watch<StartingBalanceProvider>().total;
    final balance = starting + totalIncomes - totalExpenses;

    // === ŁĄCZENIE LIST I SORTOWANIE ===
    // Zamieniamy ExpenseWithItems na Expense (nagłówek), żeby ułatwić renderowanie
    final List<dynamic> allTransactions = [
      ...expenseState.recent.map((e) => e.expense),
      ...incomeState.allIncomes,
    ];
    allTransactions.sort((a, b) => b.date.compareTo(a.date));
    // ==================================

    return Scaffold(
      appBar: AppBar(title: const Text('Mój Budżet')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Karta Salda
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      const Text('SALDO', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                          Text('Przychody: ${totalIncomes.toStringAsFixed(2)} zł', style: const TextStyle(color: Colors.green)),
                          Text('Wydatki: ${totalExpenses.toStringAsFixed(2)} zł', style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: [
                  // WYKRES SŁUPKOWY
                  MonthlyBarChart(
                    expenses: expenseState.recent,
                    incomes: incomeState.allIncomes,
                  ),
                  
                  const SizedBox(height: 12),

                  // WYKRES KOŁOWY (Kategorie wydatków)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      child: Column(
                        children: [
                          const Text('Koszty według kategorii', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          // Time range selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Zakres: '),
                              const SizedBox(width: 8),
                              DropdownButton<TimeRange>(
                                value: _selectedRange,
                                items: const [
                                  DropdownMenuItem(value: TimeRange.all, child: Text('Wszystkie')),
                                  DropdownMenuItem(value: TimeRange.year, child: Text('Rok')),
                                  DropdownMenuItem(value: TimeRange.month, child: Text('Miesiąc')),
                                  DropdownMenuItem(value: TimeRange.week, child: Text('Tydzień')),
                                  DropdownMenuItem(value: TimeRange.day, child: Text('Dzień')),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() {
                                    _selectedRange = v;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 200,
                            child: Center(
                              child: PieChartWidget(
                                data: totals,
                                // <--- ZMIANA: Przekazujemy pustą mapę lub mapujemy kolory tutaj.
                                // Ale PieChartWidget oczekuje Map<String, Color>.
                                // Najprościej jest zbudować tę mapę dynamicznie:
                                colors: Map.fromEntries(
                                  totals.keys.map((k) => MapEntry(
                                    k,
                                    categoryProvider.getColorFor(k, 'expense'),
                                  )),
                                ),
                                size: 160,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // CHIPY (LEGENDA)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: totals.keys.map((k) {
                              // <--- ZMIANA: Pobieramy kolor z Providera, zamiast ze stałej mapy
                              final c = categoryProvider.getColorFor(k, 'expense');
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

                  // LISTA TRANSAKCJI
                  Card(
                    child: Column(
                      children: [
                        const ListTile(
                          title: Text('Ostatnie transakcje', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const Divider(height: 0),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: allTransactions.length > 10 ? 10 : allTransactions.length,
                          separatorBuilder: (context, index) => const Divider(height: 0),
                          itemBuilder: (context, index) {
                            final item = allTransactions[index];

                            if (item is Income) {
                              return Dismissible(
                                key: ValueKey('inc_${item.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                                onDismissed: (_) => context.read<IncomeProvider>().deleteIncome(item.id),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: Icon(Icons.arrow_upward, color: Colors.white),
                                  ),
                                  title: Text(item.title),
                                  subtitle: Text('${DateFormat('dd.MM.yyyy').format(item.date)} • Przychód'),
                                  trailing: Text(
                                    '+${item.amount.toStringAsFixed(2)} zł',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ),
                              );
                            } else if (item is Expense) {
                              // <--- ZMIANA: Pobieramy kolor z Providera dla wydatku
                              final color = (item.categoryId != null) ? categoryProvider.getColorForId(item.categoryId) : categoryProvider.getColorFor('Inne', 'expense');
                              
                              return Dismissible(
                                key: ValueKey('exp_${item.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                                onDismissed: (_) => context.read<ExpensesState>().deleteExpense(item.id),
                                child: ListTile(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpenseScreen(expenseToEdit: item))),
                                  leading: CircleAvatar(
                                    backgroundColor: color,
                                    child: Text(((item.categoryId != null) ? categoryProvider.getNameForId(item.categoryId) : 'Inne').isNotEmpty ? ((item.categoryId != null) ? categoryProvider.getNameForId(item.categoryId) : 'Inne')[0] : '?'),
                                  ),
                                  title: Text(item.title),
                                  subtitle: Text('${DateFormat('dd.MM.yyyy').format(item.date)} • ${ (item.categoryId != null) ? categoryProvider.getNameForId(item.categoryId) : 'Inne' }'),
                                  trailing: Text(
                                    '-${item.amount.toStringAsFixed(2)} zł',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}