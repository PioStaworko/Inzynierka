// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/expenses_provider.dart';
import '../providers/income_provider.dart';

import '../models/expense_model.dart';
import '../models/income_model.dart';

import '../widgets/pie_chart_widget.dart';
import '../widgets/monthly_bar_chart.dart'; // <--- 1. DODAJ TEN IMPORT
import '../widgets/app_drawer.dart';

import '../screens/add_expense_screen.dart';
import '../screens/add_income_screen.dart';
import '../screens/add_recurring_expense_screen.dart';
import '../screens/add_recurring_income_screen.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  static const Map<String, Color> categoryColors = {
    'Food': Colors.deepOrange,
    'Transport': Colors.blue,
    'Entertainment': Colors.purple,
    'Other': Colors.green,
  };

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

    final totals = expenseState.totalsByCategory;
    final totalExpenses = totals.values.fold(0.0, (sum, item) => sum + item);
    final totalIncomes = incomeState.totalIncome;
    final balance = totalIncomes - totalExpenses;

    // === ŁĄCZENIE LIST I SORTOWANIE ===
    final List<dynamic> allTransactions = [
      ...expenseState.recent,
      ...incomeState.allIncomes
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
            // Karta Salda (Zostawiamy ją na górze, zawsze widoczną)
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

            // === ZMIANA STRUKTURY: Expanded + ListView ===
            // Dzięki temu wszystko poniżej salda będzie się przewijać
            Expanded(
              child: ListView(
                children: [
                  // <--- 2. TU WSTAWIAMY NOWY WYKRES SŁUPKOWY
                  MonthlyBarChart(
                    expenses: expenseState.recent,
                    incomes: incomeState.allIncomes,
                  ),
                  
                  const SizedBox(height: 12),

                  // Stary Wykres Kołowy
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      child: Column(
                        children: [
                          const Text('Koszty według kategorii', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

                  // === LISTA TRANSAKCJI (WSPÓLNA) ===
                  // Zauważ zmiany: shrinkWrap: true i NeverScrollableScrollPhysics
                  Card(
                    child: Column(
                      children: [
                        const ListTile(
                          title: Text('Ostatnie transakcje', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const Divider(height: 0),
                        // Zamiast Expanded używamy ListView z shrinkWrap, bo jesteśmy już wewnątrz innego ListView
                        ListView.separated(
                          shrinkWrap: true, // <--- WAŻNE: Pozwala liście zająć tylko tyle miejsca ile potrzebuje
                          physics: const NeverScrollableScrollPhysics(), // <--- WAŻNE: Wyłącza przewijanie tej wewnętrznej listy (przewija się cała strona)
                          itemCount: allTransactions.length > 10 ? 10 : allTransactions.length, // Ograniczamy do 10 ostatnich, żeby nie było za długo
                          separatorBuilder: (_, __) => const Divider(height: 0),
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
                              final color = categoryColors[item.category] ?? Colors.grey;
                              return Dismissible(
                                key: ValueKey('exp_${item.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                                onDismissed: (_) => context.read<ExpensesState>().deleteExpense(item.id),
                                child: ListTile(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpenseScreen(expenseToEdit: item))),
                                  leading: CircleAvatar(
                                    backgroundColor: color,
                                    child: Text(item.category[0]),
                                  ),
                                  title: Text(item.title),
                                  subtitle: Text('${DateFormat('dd.MM.yyyy').format(item.date)} • ${item.category}'),
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
                  // Dodatkowy odstęp na dole, żeby przycisk "+" nie zasłaniał ostatniego elementu
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