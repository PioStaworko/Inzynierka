// lib/screens/add_recurring_expense_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/recurring_expense_model.dart';
import '../providers/recurring_expense_provider.dart'; // <-- Nowy provider

class AddRecurringExpenseScreen extends StatefulWidget {
  const AddRecurringExpenseScreen({super.key});

  @override
  State<AddRecurringExpenseScreen> createState() => _AddRecurringExpenseScreenState();
}

class _AddRecurringExpenseScreenState extends State<AddRecurringExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _selectedDate = DateTime.now();
  String _selectedCategory = 'Food';
  Frequency _selectedFrequency = Frequency.monthly; // Domyślna częstotliwość

  final _categories = ['Food', 'Transport', 'Entertainment', 'Other'];

  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now, // Użytkownik nie może wybrać daty z przeszłości
      lastDate: DateTime(now.year + 5, now.month, now.day),
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitData() async { // Zmieniamy na async
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proszę wybrać datę pierwszej płatności.')),
      );
      return;
    }

    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) {
      return;
    }

    // Tworzymy nowy SZABLON
    final newRecurringExpense = RecurringExpense(
      title: _titleController.text,
      amount: enteredAmount,
      category: _selectedCategory,
      frequency: _selectedFrequency,
      nextDueDate: _selectedDate!, // To jest data pierwszej płatności
    );

    // Zapisujemy przez nowego providera
    await context.read<RecurringExpenseProvider>().addRecurringExpense(newRecurringExpense);

    if (mounted) {
      Navigator.of(context).pop();
    }
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
        title: const Text('Dodaj wydatek cykliczny'),
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
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Proszę podać tytuł.' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Kwota', suffixText: 'zł'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null || value.isEmpty || double.tryParse(value) == null) ? 'Proszę podać poprawną kwotę.' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategoria'),
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() { _selectedCategory = value; });
                },
              ),
              const SizedBox(height: 16),
              // === NOWE POLE: CZĘSTOTLIWOŚĆ ===
              DropdownButtonFormField<Frequency>(
                value: _selectedFrequency,
                decoration: const InputDecoration(labelText: 'Częstotliwość'),
                items: Frequency.values.map((freq) {
                  // Proste "tłumaczenie" enuma
                  String text = freq.name == 'daily' ? 'Codziennie' :
                                freq.name == 'weekly' ? 'Tygodniowo' :
                                freq.name == 'monthly' ? 'Miesięcznie' : 'Rocznie';
                  return DropdownMenuItem(value: freq, child: Text(text));
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() { _selectedFrequency = value; });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate == null ? 'Nie wybrano daty' : 'Data 1. płatności: ${DateFormat('dd.MM.yyyy').format(_selectedDate!)}',
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _presentDatePicker,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submitData,
                icon: const Icon(Icons.save),
                label: const Text('Zapisz szablon'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}