// lib/screens/add_expense_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense_model.dart';
import '../providers/expenses_provider.dart';

// DODANY IMPORT MODELU KATEGORII (jeśli masz inny plik, dostosuj ścieżkę)
import '../models/category_model.dart';
import '../widgets/category_selector.dart';

class AddExpenseScreen extends StatefulWidget {
  // Opcjonalny parametr: jeśli jest null = tryb dodawania, jeśli jest obiekt = tryb edycji
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
  String _selectedCategory = 'Food';
  // lista kategorii usunięta — używamy CategorySelector

  @override
  void initState() {
    super.initState();
    // LOGIKA INICJALIZACJI: Sprawdzamy, czy jesteśmy w trybie edycji
    if (widget.expenseToEdit != null) {
      final e = widget.expenseToEdit!;
      _titleController = TextEditingController(text: e.title);
      _amountController = TextEditingController(text: e.amount.toString());
      _selectedDate = e.date;
      _selectedCategory = e.category;
    } else {
      // Tryb dodawania - puste pola
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
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month - 6, now.day),
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

    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) return;

    // Tworzymy obiekt
    final expense = Expense(
      title: _titleController.text,
      amount: enteredAmount,
      category: _selectedCategory,
      date: _selectedDate!,
    );

    // DECYZJA: Edycja czy Dodawanie?
    if (widget.expenseToEdit != null) {
      // WAŻNE: Musimy przepisać ID ze starego obiektu!
      expense.id = widget.expenseToEdit!.id;
      await context.read<ExpensesState>().updateExpense(expense);
    } else {
      await context.read<ExpensesState>().addExpense(expense);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Zmieniamy tytuł w zależności od trybu
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
                validator: (val) => (val == null || double.tryParse(val) == null) ? 'Błędna kwota' : null,
              ),
              const SizedBox(height: 16),
              // Nowy selektor kategorii
              CategorySelector(
                type: CategoryType.expense,
                initialValue: _selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Data po prawej
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