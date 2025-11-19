// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/expenses_provider.dart';
import '../providers/income_provider.dart';
import '../providers/category_provider.dart'; // <--- ZMIANA: Dodano import

import '../models/expense_model.dart';
import '../models/income_model.dart';
import '../models/category_model.dart'; // <--- ZMIANA: Dodano import (dla CategoryType)

import '../widgets/pie_chart_widget.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/app_drawer.dart';

import '../screens/add_expense_screen.dart';
import '../screens/add_income_screen.dart';
import '../screens/add_recurring_expense_screen.dart';
import '../screens/add_recurring_income_screen.dart';
import '../screens/scan_receipt_screen.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
                                    categoryProvider.getColorFor(k, CategoryType.expense)
                                  ))
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
                              final c = categoryProvider.getColorFor(k, CategoryType.expense);
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
                              // <--- ZMIANA: Pobieramy kolor z Providera dla wydatku
                              final color = categoryProvider.getColorFor(item.category, CategoryType.expense);
                              
                              return Dismissible(
                                key: ValueKey('exp_${item.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                                onDismissed: (_) => context.read<ExpensesState>().deleteExpense(item.id),
                                child: ListTile(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpenseScreen(expenseToEdit: item))),
                                  leading: CircleAvatar(
                                    backgroundColor: color,
                                    child: Text(item.category.isNotEmpty ? item.category[0] : '?'),
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