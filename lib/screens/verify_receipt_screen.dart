// lib/screens/verify_receipt_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';

import '../models/expense_model.dart';
import '../models/product_mapping_model.dart';
import '../models/category_model.dart';
import '../providers/expenses_provider.dart';
import '../widgets/category_selector.dart';

class VerifyReceiptScreen extends StatefulWidget {
  final List<ExpenseItem> parsedItems;
  final double totalSum;

  const VerifyReceiptScreen({
    super.key, 
    required this.parsedItems,
    this.totalSum = 0.0,
  });

  @override
  State<VerifyReceiptScreen> createState() => _VerifyReceiptScreenState();
}

class _VerifyReceiptScreenState extends State<VerifyReceiptScreen> {
  late List<ExpenseItem> _items;
  final _titleController = TextEditingController(text: 'Zakupy (Paragon)');
  late Isar _isar;

  @override
  void initState() {
    super.initState();
    // Tworzymy kopię listy, aby móc ją swobodnie edytować
    _items = List.from(widget.parsedItems);
    _isar = context.read<ExpensesState>().isar; 
    
    _autoCategorizeItems(); 
  }

  Future<void> _autoCategorizeItems() async {
    for (var item in _items) {
      if (item.rawId == null) continue;

      // Sprawdzamy, czy znamy ten kod z paragonu (rawId)
      final mapping = await _isar.productMappings
          .filter()
          .rawIdEqualTo(item.rawId!)
          .findFirst();

      if (mapping != null) {
        setState(() {
          // AUTOMATYZACJA:
          // Jeśli produkt jest znany, podmieniamy jego nazwę na tę "ładną" (knownName)
          // którą użytkownik wpisał ostatnim razem.
          item.name = mapping.knownName; 
          item.category = mapping.defaultCategory;
        });
      }
    }
  }

  double get _currentTotal => _items.fold(0.0, (sum, item) => sum + item.amount);

  Future<void> _saveReceipt() async {
    if (_items.isEmpty) return;

    final mappingsToSave = <ProductMapping>[];
    
    for (var item in _items) {
      // UCZENIE SIĘ:
      // Zapisujemy parę: [Kod z Paragonu] -> [Nazwa wpisana przez usera] + [Kategoria]
      if (item.rawId != null && item.category != 'Other') {
        mappingsToSave.add(ProductMapping(
          rawId: item.rawId!, 
          knownName: item.name ?? item.rawId!, // Tu zapisujemy edytowaną nazwę!
          defaultCategory: item.category,
        ));
      }
    }

    if (mappingsToSave.isNotEmpty) {
      await _isar.writeTxn(() async {
        await _isar.productMappings.putAll(mappingsToSave);
      });
    }

    final expense = Expense(
      title: _titleController.text,
      amount: _currentTotal,
      category: 'Zakupy',
      date: DateTime.now(),
      items: _items,
    );

    await context.read<ExpensesState>().addExpense(expense);

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paragon zapisany i zapamiętany!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weryfikacja Paragonu')),
      body: Column(
        children: [
          // Nagłówek
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Nazwa paragonu'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Suma całkowita:'),
                        Text(
                          '${_currentTotal.toStringAsFixed(2)} zł',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          
          // Lista pozycji
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                
                // KLUCZ DO ROZWIĄZANIA PROBLEMU USUWANIA:
                // Używamy ObjectKey(item), aby Flutter wiedział, że ten widget
                // jest na sztywno przypisany do tej konkretnej instancji obiektu w pamięci.
                return Card(
                  key: ObjectKey(item), // <--- TO NAPRAWIA BŁĄD USUWANIA
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            // Używamy initialValue, bo przy ObjectKey widget i tak zostanie
                            // stworzony od nowa, jeśli dane się zmienią.
                            initialValue: item.name,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Nazwa produktu',
                              isDense: true,
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            // Tu edytujemy nazwę, która zostanie zapamiętana w bazie wiedzy
                            onChanged: (val) => item.name = val,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            initialValue: item.amount.toStringAsFixed(2),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
                            decoration: const InputDecoration(
                              suffixText: ' zł', 
                              border: InputBorder.none,
                              labelText: 'Cena',
                              isDense: true,
                            ),
                            onChanged: (val) {
                              setState(() {
                                item.amount = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      item.category, 
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)
                    ),
                    
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            // Oryginalna nazwa z paragonu (dla informacji)
                            if (item.rawId != null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    "Kod z paragonu: ${item.rawId}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ),
                              
                            CategorySelector(
                              type: CategoryType.expense,
                              initialValue: item.category,
                              onChanged: (newCat) {
                                setState(() {
                                  item.category = newCat;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            // Dzięki ObjectKey, to usunie właściwą kartę
                            _items.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Usuń tę pozycję', style: TextStyle(color: Colors.red)),
                      )
                    ],
                  ),
                );
              },
            ),
          ),

          // Przycisk zapisu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saveReceipt,
                icon: const Icon(Icons.save),
                label: const Text('Zapisz i Zapamiętaj'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}