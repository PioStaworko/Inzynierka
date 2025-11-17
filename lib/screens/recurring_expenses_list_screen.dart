// lib/screens/recurring_expenses_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/recurring_expense_provider.dart';

class RecurringExpensesListScreen extends StatelessWidget {
  const RecurringExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Nasłuchujemy zmian w providerze
    final provider = context.watch<RecurringExpenseProvider>();
    final templates = provider.allTemplates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wydatki Cykliczne'),
      ),
      body: templates.isEmpty
          ? const Center(
              child: Text('Nie masz jeszcze żadnych szablonów wydatków cyklicznych.'),
            )
          : ListView.builder(
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                
                return Dismissible(
                  key: ValueKey(template.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red.shade700,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    // Wywołujemy usuwanie z providera
                    context
                        .read<RecurringExpenseProvider>()
                        .deleteRecurringExpense(template.id);
                  },
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.replay),
                    ),
                    title: Text(template.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Następna płatność: ${DateFormat('dd.MM.yyyy').format(template.nextDueDate)}'
                    ),
                    trailing: Text(
                      '${template.amount.toStringAsFixed(2)} zł',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
    );
  }
}