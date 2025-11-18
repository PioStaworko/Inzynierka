// lib/screens/add_recurring_expense_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/recurring_income_model.dart';
import '../providers/recurring_income_provider.dart';

class AddRecurringIncomeScreen extends StatefulWidget {
  final RecurringIncome? incomeToEdit; // Opcjonalny parametr do edycji

  const AddRecurringIncomeScreen({super.key, this.incomeToEdit});

  @override
  State<AddRecurringIncomeScreen> createState() => _AddRecurringIncomeScreenState();
}

class _AddRecurringIncomeScreenState extends State<AddRecurringIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  DateTime? _selectedDate;
  String _selectedCategory = 'Food';
  Frequency _selectedFrequency = Frequency.monthly;
  final _categories = ['Food', 'Transport', 'Entertainment', 'Other'];

  @override
  void initState() {
    super.initState();
    // LOGIKA INICJALIZACJI
    if (widget.incomeToEdit != null) {
      final i = widget.incomeToEdit!;
      _titleController = TextEditingController(text: i.title);
      _amountController = TextEditingController(text: i.amount.toString());
      _selectedDate = i.nextDueDate;
      _selectedCategory = i.source;
      _selectedFrequency = i.frequency;
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
      firstDate: DateTime(now.year, now.month - 6, now.day),
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate != null) {
      setState(() { _selectedDate = pickedDate; });
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) return;
    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) return;

    final recurringIncome = RecurringIncome(
      title: _titleController.text,
      amount: enteredAmount,
      source: _selectedCategory,
      frequency: _selectedFrequency,
      nextDueDate: _selectedDate!,
    );

    if (widget.incomeToEdit != null) {
      // Tryb EDYCJI: Przepisujemy ID
      recurringIncome.id = widget.incomeToEdit!.id;
      await context.read<RecurringIncomeProvider>().updateRecurringIncome(recurringIncome);
    } else {
      // Tryb DODAWANIA
      await context.read<RecurringIncomeProvider>().addRecurringIncome(recurringIncome);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.incomeToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edytuj szablon' : 'Dodaj przychód cykliczny'),
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
                validator: (val) => (val == null || val.isEmpty) ? 'Wpisz tytuł' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Kwota', suffixText: 'zł'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => (val == null || double.tryParse(val) == null) ? 'Błędna kwota' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Źródło'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Frequency>(
                value: _selectedFrequency,
                decoration: const InputDecoration(labelText: 'Częstotliwość'),
                items: Frequency.values.map((f) {
                  String label = f == Frequency.monthly ? 'Miesięcznie' : 
                                 f == Frequency.weekly ? 'Tygodniowo' : 
                                 f == Frequency.yearly ? 'Rocznie' : 'Codziennie';
                  return DropdownMenuItem(value: f, child: Text(label));
                }).toList(),
                onChanged: (val) => setState(() => _selectedFrequency = val!),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_selectedDate == null ? 'Brak daty' : 'Następna: ${DateFormat('dd.MM.yyyy').format(_selectedDate!)}'),
                  IconButton(icon: const Icon(Icons.calendar_month), onPressed: _presentDatePicker),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submitData,
                icon: Icon(isEditing ? Icons.save_as : Icons.save),
                label: Text(isEditing ? 'Zapisz zmiany' : 'Zapisz szablon'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}