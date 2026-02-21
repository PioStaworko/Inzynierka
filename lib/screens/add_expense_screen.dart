import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../providers/category_provider.dart';

import '../data/app_database.dart'; 
import '../providers/expenses_provider.dart';
import '../widgets/category_selector.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpenseScreen({super.key, this.expenseToEdit});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  
  DateTime? _selectedDate;
  String _selectedCategory = 'Inne';
  bool _isSaving = false;
  List<_EditableItem> _items = [];

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final e = widget.expenseToEdit!;
      _titleController = TextEditingController(text: e.title);
      _amountController = TextEditingController(text: e.amount.toString());
      _selectedDate = e.date;
      try {
        final catProv = Provider.of<CategoryProvider>(context, listen: false);
        _selectedCategory = catProv.getNameForId(e.categoryId);
      } catch (_) {
        _selectedCategory = 'Inne';
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final expState = Provider.of<ExpensesState>(context, listen: false);
          final match = expState.recent.firstWhere((r) => r.expense.id == e.id, orElse: () => ExpenseWithItems(e, []));
          final catProv = Provider.of<CategoryProvider>(context, listen: false);
          _items = match.items.map((it) {
            final ed = _EditableItem.fromExpenseItem(it);
            try {
              ed.categoryName = it.categoryId != null ? catProv.getNameForId(it.categoryId) : null;
            } catch (_) {
              ed.categoryName = null;
            }
            return ed;
          }).toList();
          setState(() {});
        } catch (_) {}
      });
    } else {
      _titleController = TextEditingController();
      _amountController = TextEditingController();
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 2), // Pozwalamy cofnąć się o 2 lata
      lastDate: now,
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _showAddItemDialog() async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selCategory = 'Inne';

    await showDialog<void>(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Dodaj pozycję'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nazwa')),
              TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Kwota'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 8),
              CategorySelector(
                type: 'expense',
                initialValue: selCategory,
                onChanged: (v) => selCategory = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Anuluj')),
          ElevatedButton(onPressed: () {
            final n = nameCtrl.text.trim();
            final a = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0.0;
            if (n.isEmpty) return;
            int? catId;
            try {
              final catProv = Provider.of<CategoryProvider>(context, listen: false);
              catId = catProv.expenseCategories.firstWhere((c) => c.name == selCategory).id;
            } catch (_) { catId = null; }
            setState(() {
              _items.add(_EditableItem(name: n, amount: a, categoryId: catId, categoryName: selCategory));
            });
            Navigator.of(ctx).pop();
          }, child: const Text('Dodaj')),
        ],
      );
    });
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) return;

    final enteredAmount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (enteredAmount == null || enteredAmount <= 0) return;

    final provider = context.read<ExpensesState>();
    if (_isSaving) return; // zapobiegamy wielokrotnemu wciśnięciu
    setState(() => _isSaving = true);

    if (widget.expenseToEdit != null) {
      final catProv = Provider.of<CategoryProvider>(context, listen: false);
      int? selectedId;
      try {
        selectedId = catProv.expenseCategories.firstWhere((c) => c.name == _selectedCategory).id;
      } catch (_) {
        await catProv.addCategory(_selectedCategory, 'expense', Colors.grey);
        selectedId = catProv.expenseCategories.firstWhere((c) => c.name == _selectedCategory).id;
      }

      final updatedExpense = widget.expenseToEdit!.copyWith(
        title: _titleController.text,
        amount: enteredAmount,
        date: _selectedDate!,
        categoryId: drift.Value(selectedId),
      );
      final companions = _items.map((it) => ExpenseItemsCompanion.insert(
        expenseId: 0,
        name: it.name,
        amount: it.amount,
        categoryId: drift.Value(it.categoryId),
      )).toList();

      await provider.updateExpenseWithItems(updatedExpense, companions);
    } else {
      final companions = _items.map((it) => ExpenseItemsCompanion.insert(
        expenseId: 0,
        name: it.name,
        amount: it.amount,
        categoryId: drift.Value(it.categoryId),
      )).toList();

      await provider.addExpense(
        title: _titleController.text,
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory,
        items: companions,
      );
    }

    if (mounted) Navigator.of(context).pop();
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expenseToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edytuj wydatek' : 'Dodaj nowy wydatek'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tytuł'),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Wpisz tytuł' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Kwota', suffixText: 'zł'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => (val == null || double.tryParse(val.replaceAll(',', '.')) == null) ? 'Błędna kwota' : null,
              ),
              const SizedBox(height: 16),
              
              CategorySelector(
                type: 'expense', // String zamiast Enum (zgodnie z bazą)
                initialValue: _selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Pozycje (opcjonalnie)', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            onPressed: _showAddItemDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Dodaj pozycję'),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_items.isEmpty) const Text('Brak pozycji. Możesz dodać ręcznie.')
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          itemBuilder: (ctx, idx) {
                            final it = _items[idx];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ExpansionTile(
                                title: Text(it.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${it.amount.toStringAsFixed(2)} zł — ${it.categoryName ?? 'Inne'}'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          initialValue: it.name,
                                          decoration: const InputDecoration(labelText: 'Nazwa pozycji'),
                                          onChanged: (v) => it.name = v,
                                        ),
                                        TextFormField(
                                          initialValue: it.amount.toStringAsFixed(2),
                                          decoration: const InputDecoration(labelText: 'Kwota', suffixText: 'zł'),
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          onChanged: (v) => it.amount = double.tryParse(v.replaceAll(',', '.')) ?? 0.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top:8.0),
                                          child: CategorySelector(
                                            type: 'expense',
                                            initialValue: it.categoryName ?? 'Inne',
                                            onChanged: (val) async {
                                              it.categoryName = val;
                                              try {
                                                final catProv = Provider.of<CategoryProvider>(context, listen: false);
                                                it.categoryId = catProv.expenseCategories.firstWhere((c) => c.name == val).id;
                                              } catch (_) { it.categoryId = null; }
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () {
                                              setState(() { _items.removeAt(idx); });
                                            },
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            label: const Text('Usuń', style: TextStyle(color: Colors.red)),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_selectedDate == null ? 'Brak daty' : DateFormat('dd.MM.yyyy').format(_selectedDate!)),
                  IconButton(icon: const Icon(Icons.calendar_month), onPressed: _presentDatePicker),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _submitData,
                icon: _isSaving ? const SizedBox(width:16, height:16, child: CircularProgressIndicator(strokeWidth:2)) : Icon(isEditing ? Icons.save_as : Icons.save),
                label: Text(_isSaving ? 'Trwa zapisywanie...' : (isEditing ? 'Zapisz zmiany' : 'Dodaj wydatek')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditableItem {
  int? id;
  int? categoryId;
  String? categoryName;
  String name;
  double amount;

  _EditableItem({this.id, this.categoryId, this.categoryName, required this.name, required this.amount});

  factory _EditableItem.fromExpenseItem(ExpenseItem it) => _EditableItem(
    id: it.id,
    categoryId: it.categoryId,
    categoryName: null,
    name: it.name,
    amount: it.amount,
  );
}