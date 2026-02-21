import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/recurring_income_provider.dart';
import '../screens/add_recurring_income_screen.dart';

class RecurringIncomeListScreen extends StatelessWidget {
  const RecurringIncomeListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecurringIncomeProvider>();
    final templates = provider.allTemplates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Przychody stałe'),
      ),
      body: templates.isEmpty
          ? const Center(
              child: Text('Nie masz jeszcze żadnych szablonów przychodów stałych'),
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
                    context
                        .read<RecurringIncomeProvider>()
                        .deleteRecurringIncome(template.id);
                  },
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddRecurringIncomeScreen(incomeToEdit: template), // Przekazujemy obiekt 'template'
                        ),
                      );
                    },

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