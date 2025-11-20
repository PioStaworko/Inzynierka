// lib/screens/add_expense_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// IMPORT KLAS DRIFT (Zamiast ../models/expense_model.dart)
import '../data/app_database.dart'; 
import '../providers/expenses_provider.dart';
import '../widgets/category_selector.dart';

class AddExpenseScreen extends StatefulWidget {
  // Używamy klasy 'Expense' wygenerowanej przez Drift
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
  String _selectedCategory = 'Inne'; // Domyślna kategoria

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final e = widget.expenseToEdit!;
      _titleController = TextEditingController(text: e.title);
      _amountController = TextEditingController(text: e.amount.toString());
      _selectedDate = e.date;
      // W Drift kategoria jest w polu categoryName (zgodnie z tabelą)
      _selectedCategory = e.categoryName; 
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

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) return;

    final enteredAmount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (enteredAmount == null || enteredAmount <= 0) return;

    final provider = context.read<ExpensesState>();

    if (widget.expenseToEdit != null) {
      // EDYCJA
      // Tworzymy zmodyfikowany obiekt Expense (Drift generuje metodę copyWith)
      final updatedExpense = widget.expenseToEdit!.copyWith(
        title: _titleController.text,
        amount: enteredAmount,
        categoryName: _selectedCategory,
        date: _selectedDate!,
      );
      await provider.updateExpense(updatedExpense);
    } else {
      // DODAWANIE
      // Provider używa teraz nazwanych argumentów
      await provider.addExpense(
        title: _titleController.text,
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory,
        items: [], // Pusta lista produktów dla ręcznego wpisu
      );
    }

    if (mounted) Navigator.of(context).pop();
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
              
              // SELEKTOR KATEGORII
              // UWAGA: CategorySelector musi być przystosowany do Stringów
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_selectedDate == null ? 'Brak daty' : DateFormat('dd.MM.yyyy').format(_selectedDate!)),
                  IconButton(icon: const Icon(Icons.calendar_month), onPressed: _presentDatePicker),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submitData,
                icon: Icon(isEditing ? Icons.save_as : Icons.save),
                label: Text(isEditing ? 'Zapisz zmiany' : 'Dodaj wydatek'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}