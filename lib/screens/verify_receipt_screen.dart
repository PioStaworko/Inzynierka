// lib/screens/verify_receipt_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;

// Importujemy bazę danych i parser
import '../data/app_database.dart';
import '../utils/receipt_parser.dart'; // Tu jest ParsedItem
import '../providers/expenses_provider.dart';
import '../widgets/category_selector.dart';

class VerifyReceiptScreen extends StatefulWidget {
  final List<ParsedItem> parsedItems;
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
  late List<ParsedItem> _items;
  final _titleController = TextEditingController(text: 'Zakupy (Paragon)');
  late RecurringDao _recurringDao; // DAO do obsługi ProductMappings

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.parsedItems);
    // Pobieramy bazę danych, żeby dostać się do DAO
    final db = context.read<AppDb>();
    _recurringDao = db.recurringDao;
    
    _autoCategorizeItems(); 
  }

  Future<void> _autoCategorizeItems() async {
    // Pobieramy wszystkie mapowania z bazy
    final mappings = await _recurringDao.getAllMappings();
    final db = context.read<AppDb>();
    final allCats = await db.categoriesDao.getAllCategories();
    final catMap = {for (var c in allCats) c.id: c.name};
    final updates = <int, Map<String, String>>{}; // index -> {'name':..., 'category':...}

    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.rawId == null) continue;
        try {
        final mapping = mappings.firstWhere((m) => m.rawId == item.rawId);
        String catName = 'Inne';
        if (mapping.defaultCategoryId != null) {
          catName = catMap[mapping.defaultCategoryId] ?? 'Inne';
        }
        updates[i] = {'name': mapping.knownName, 'category': catName};
      } catch (e) {
        // Nie znaleziono - zostaje 'Inne'
      }
    }

    if (updates.isNotEmpty && mounted) {
      setState(() {
        updates.forEach((idx, map) {
          _items[idx].name = map['name']!;
          _items[idx].category = map['category']!;
        });
      });
    }
  }

  double get _currentTotal => _items.fold(0.0, (sum, item) => sum + item.amount);

  Future<void> _saveReceipt() async {
    if (_items.isEmpty) return;

    // 1. Uczenie się (Zapisujemy ProductMappings)
    final db = context.read<AppDb>();
    final allCats = await db.categoriesDao.getAllCategories();
    for (var item in _items) {
        if (item.rawId != null && item.category != 'Inne') {
        Category? matched;
        try {
          matched = allCats.firstWhere((c) => c.name == item.category);
        } catch (_) {
          matched = null;
        }
        int? catId = matched?.id;
        if (catId == null) {
          await db.categoriesDao.insertCategory(CategoriesCompanion.insert(name: item.category, type: 'expense', colorValue: 4286578816));
          final refreshed = await db.categoriesDao.getAllCategories();
          try {
            catId = refreshed.firstWhere((c) => c.name == item.category).id;
          } catch (_) {
            catId = null;
          }
        }
        final mappingEntry = ProductMappingsCompanion.insert(
          rawId: item.rawId!,
          knownName: item.name,
          defaultCategoryId: drift.Value(catId),
        );
        // set id via a manual statement if the companion supports defaultCategoryId after codegen
        await _recurringDao.addMapping(mappingEntry);
        // If new column exists, update it
        try {
          await db.customStatement('UPDATE product_mappings SET default_category_id = ? WHERE raw_id = ?', [catId, item.rawId]);
        } catch (_) {}
      }
    }

    // 2. Zapis Wydatku i Pozycji (Drift)
    // Lista pozycji do wstawienia
    // Build ExpenseItemsCompanion list, resolving category names to IDs where possible
    final freshCats = await db.categoriesDao.getAllCategories();
    final expenseItems = _items.map((i) {
      Category? matched;
      try {
        matched = freshCats.firstWhere((c) => c.name == i.category);
      } catch (_) {
        matched = null;
      }
      final catId = matched?.id;
      return ExpenseItemsCompanion.insert(
        expenseId: 0, // Placeholder, zostanie nadpisany w transakcji
        name: i.name,
        amount: i.amount,
        categoryId: drift.Value(catId),
      );
    }).toList();

    await context.read<ExpensesState>().addExpense(
      title: _titleController.text,
      amount: _currentTotal,
      date: DateTime.now(),
      category: 'Zakupy', // Główna kategoria paragonu
      items: expenseItems,
    );

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
          
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                
                // ObjectKey jest kluczowy przy usuwaniu
                return Card(
                  key: ObjectKey(item),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: item.name,
                            decoration: const InputDecoration(border: InputBorder.none),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            onChanged: (val) => item.name = val,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            initialValue: item.amount.toStringAsFixed(2),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
                            decoration: const InputDecoration(suffixText: ' zł', border: InputBorder.none),
                            onChanged: (val) {
                              setState(() {
                                item.amount = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(item.category, style: TextStyle(color: Colors.grey[600])),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: CategorySelector(
                          type: 'expense', // String!
                          initialValue: item.category,
                          onChanged: (newCat) {
                            setState(() {
                              item.category = newCat;
                            });
                          },
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _items.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Usuń pozycję', style: TextStyle(color: Colors.red)),
                      )
                    ],
                  ),
                );
              },
            ),
          ),

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