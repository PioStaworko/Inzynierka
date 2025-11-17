// lib/screens/add_expense_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pamiętaj, aby dodać 'intl' do pubspec.yaml
import 'package:provider/provider.dart';

import '../models/expense_model.dart';
import '../providers/expenses_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // Klucz do walidacji formularza
  final _formKey = GlobalKey<FormState>();

  // Kontrolery dla pól tekstowych
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  // Zmienne do przechowywania wybranych wartości
  DateTime? _selectedDate = DateTime.now();
  String _selectedCategory = 'Food'; // Domyślna kategoria

  // Hardkodowana lista kategorii (docelowo powinna być w providerze)
  final _categories = ['Food', 'Transport', 'Entertainment', 'Other'];

  // Funkcja do pokazywania okna wyboru daty
  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  // Funkcja do zapisywania formularza
  Future<void> _submitData() async {
    // Walidacja
    if (!_formKey.currentState!.validate()) {
      return; // Przerwij, jeśli walidacja się nie powiodła
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proszę wybrać datę.')),
      );
      return;
    }

    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proszę podać poprawną kwotę.')),
      );
      return;
    }

    // Stworzenie nowego wydatku
    final newExpense = Expense(
      title: _titleController.text,
      amount: enteredAmount,
      category: _selectedCategory,
      date: _selectedDate!,
    );

    // Dodanie przez providera (bez słuchania zmian)
    await context.read<ExpensesState>().addExpense(newExpense);

    // Zamknięcie ekranu dodawania
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj nowy wydatek'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( // ListView zapobiega błędom "overflow" przy klawiaturze
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tytuł'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Proszę podać tytuł.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Kwota', suffixText: 'zł'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Proszę podać poprawną kwotę.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategoria'),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'Nie wybrano daty'
                              : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: _presentDatePicker,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submitData,
                icon: const Icon(Icons.save),
                label: const Text('Zapisz wydatek'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}