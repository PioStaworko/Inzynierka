import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/savings_goals_provider.dart';
import '../data/app_database.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SavingsGoalsProvider>(context);
    final goals = provider.goals;

    return Scaffold(
      appBar: AppBar(title: const Text('Cele oszczędnościowe')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showAddDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Dodaj cel'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: goals.isEmpty
                  ? const Center(child: Text('Brak celów. Dodaj pierwszy!'))
                  : ListView.separated(
                      itemCount: goals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final g = goals[i];
                        final prog = g.progress;
                        
                        // Używamy savedAmount (netto)
                        final currentSaved = g.savedAmount;
                        final target = g.goal.targetAmount;
                        final remaining = (target - currentSaved).clamp(0.0, double.infinity);

                        // Kolor paska:
                        // Czerwony jeśli jesteśmy na minusie (wydaliśmy więcej niż zarobiliśmy w tym okresie)
                        // Zielony standardowo
                        // Złoty jeśli cel osiągnięty
                        Color progressColor = Colors.green;
                        if (currentSaved < 0) progressColor = Colors.red;
                        else if (currentSaved >= target) progressColor = Colors.amber;

                        return Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        g.goal.title, 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ),
                                    Text(
                                      'Cel: ${target.toStringAsFixed(0)} zł',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Pasek postępu
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: prog, 
                                    minHeight: 12,
                                    backgroundColor: Colors.grey[300],
                                    color: progressColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Szczegóły kwotowe
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Uzbierano: ${currentSaved.toStringAsFixed(2)} zł',
                                          style: TextStyle(
                                            color: currentSaved < 0 ? Colors.red : Colors.black87,
                                            fontWeight: FontWeight.w500
                                          ),
                                        ),
                                        if (currentSaved < 0)
                                          const Text(
                                            '(Wydatki przekraczają dochody!)',
                                            style: TextStyle(color: Colors.red, fontSize: 10),
                                          ),
                                      ],
                                    ),
                                    // Przycisk usuwania
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.grey),
                                      onPressed: () => provider.deleteGoal(g.goal.id),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext ctx) async {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    DateTime? start;
    DateTime? end;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: ctx,
      builder: (dctx) {
        return AlertDialog(
          title: const Text('Nowy cel oszczędnościowy'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Tytuł'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wprowadź tytuł' : null,
                  ),
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Kwota do odłożenia (PLN)'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Wprowadź kwotę';
                      final p = double.tryParse(v.replaceAll(',', '.'));
                      if (p == null || p <= 0) return 'Niepoprawna kwota';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) start = picked;
                          },
                          child: const Text('Wybierz datę początku'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now().add(const Duration(days: 30)),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) end = picked;
                          },
                          child: const Text('Wybierz datę końca'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dctx).pop(), child: const Text('Anuluj')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (start == null || end == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Wybierz okres')));
                  return;
                }
                final title = titleCtrl.text.trim();
                final amount = double.parse(amountCtrl.text.replaceAll(',', '.'));
                try {
                  await Provider.of<SavingsGoalsProvider>(ctx, listen: false).addGoal(title, amount, start!, end!);
                  if (mounted) {
                    Navigator.of(dctx).pop();
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Cel dodany')));
                  }
                } catch (e) {
                  // Show error so user sees what went wrong when insertion fails
                  if (mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Błąd dodawania celu: $e')));
                  }
                }
              },
              child: const Text('Dodaj'),
            ),
          ],
        );
      },
    );
  }
}
