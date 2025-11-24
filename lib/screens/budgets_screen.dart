// lib/screens/budget_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../data/app_database.dart'; // Import klas Drift
import '../providers/category_provider.dart';
import '../widgets/category_selector.dart'; // Użyjemy do wyboru kategorii

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Moje Budżety')),
      body: StreamBuilder<List<BudgetWithProgress>>(
        stream: db.budgetsDao.watchAllBudgets(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Błąd podczas ładowania budżetów: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          
          if (items.isEmpty) {
            return const Center(child: Text("Brak ustawionych budżetów. Dodaj pierwszy!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _BudgetCard(item: item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Żeby klawiatura nie zasłaniała
      builder: (ctx) => const AddBudgetSheet(),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetWithProgress item;
  const _BudgetCard({required this.item});

  @override
  Widget build(BuildContext context) {
    // Kolor paska zależny od procentu (zielony -> żółty -> czerwony)
    Color progressColor = Colors.green;
    if (item.progress >= 1.0) progressColor = Colors.red;
    else if (item.progress >= 0.8) progressColor = Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // Resolve categoryId -> name
                  Provider.of<CategoryProvider>(context, listen: false).getNameForId(item.budget.categoryId),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () {
                    context.read<AppDb>().budgetsDao.deleteBudget(item.budget.id);
                  },
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Wykorzystano: ${item.percent.toStringAsFixed(1)}%'),
                Text('${item.spent.toStringAsFixed(2)} / ${item.budget.amountLimit.toStringAsFixed(0)} zł'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: item.progress,
              color: progressColor,
              backgroundColor: Colors.grey[300],
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 4),
            Text(
              'Okres: ${_translatePeriod(item.budget.period)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _translatePeriod(String period) {
    switch (period) {
      case 'week': return 'Tygodniowy';
      case 'month': return 'Miesięczny';
      case 'year': return 'Roczny';
      default: return period;
    }
  }
}

// Formularz dodawania w osobnym widgecie
class AddBudgetSheet extends StatefulWidget {
  const AddBudgetSheet({super.key});

  @override
  State<AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<AddBudgetSheet> {
  String _selectedCategory = 'Jedzenie'; // Domyślnie
  String _period = 'month';
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ustal nowy budżet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          CategorySelector(
            type: 'expense',
            initialValue: _selectedCategory,
            onChanged: (val) => setState(() => _selectedCategory = val),
          ),
          
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _period,
            decoration: const InputDecoration(labelText: 'Okres'),
            items: const [
              DropdownMenuItem(value: 'week', child: Text('Tydzień')),
              DropdownMenuItem(value: 'month', child: Text('Miesiąc')),
              DropdownMenuItem(value: 'year', child: Text('Rok')),
            ],
            onChanged: (val) => setState(() => _period = val!),
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Limit kwotowy (zł)'),
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  final dao = context.read<AppDb>().budgetsDao;
                  // Resolve selected category name -> id (create if missing)
                  final catProv = Provider.of<CategoryProvider>(context, listen: false);
                  int? cid;
                  try {
                    cid = catProv.expenseCategories.firstWhere((c) => c.name == _selectedCategory).id;
                  } catch (_) {
                    await catProv.addCategory(_selectedCategory, 'expense', Colors.grey);
                    cid = catProv.expenseCategories.firstWhere((c) => c.name == _selectedCategory).id;
                  }
                  await dao.addBudget(BudgetsCompanion.insert(
                    categoryId: drift.Value(cid),
                    amountLimit: amount,
                    period: _period,
                  ));
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Zapisz Budżet'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}