// lib/screens/add_recurring_income_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/app_database.dart';
import '../providers/recurring_income_provider.dart';
import '../widgets/category_selector.dart';

class AddRecurringIncomeScreen extends StatefulWidget {
  final RecurringIncome? incomeToEdit;

  const AddRecurringIncomeScreen({super.key, this.incomeToEdit});

  @override
  State<AddRecurringIncomeScreen> createState() => _AddRecurringIncomeScreenState();
}

class _AddRecurringIncomeScreenState extends State<AddRecurringIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  DateTime? _selectedDate;
  String _selectedCategory = 'Inne';
  String _selectedFrequency = 'monthly'; // String zamiast Enum

  @override
  void initState() {
    super.initState();
    if (widget.incomeToEdit != null) {
      final e = widget.incomeToEdit!;
      _titleController = TextEditingController(text: e.title);
      _amountController = TextEditingController(text: e.amount.toString());
      _selectedDate = e.nextDueDate;
      _selectedCategory = e.source;
      _selectedFrequency = e.frequency;
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
     // ... standardowy date picker ...
     final now = DateTime.now();
     final pickedDate = await showDatePicker(context: context, initialDate: _selectedDate ?? now, firstDate: now, lastDate: DateTime(now.year + 5));
     if(pickedDate != null) setState(() => _selectedDate = pickedDate);
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) return;
    final enteredAmount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (enteredAmount == null || enteredAmount <= 0) return;

    final provider = context.read<RecurringIncomeProvider>();

    if (widget.incomeToEdit != null) {
      final updated = widget.incomeToEdit!.copyWith(
        title: _titleController.text,
        amount: enteredAmount,
        source: _selectedCategory,
        frequency: _selectedFrequency,
        nextDueDate: _selectedDate!,
      );
      await provider.updateRecurringIncome(updated);
    } else {
      await provider.addRecurringIncome(
        _titleController.text,
        enteredAmount,
        _selectedCategory,
        _selectedFrequency,
        _selectedDate!,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Przychody cykliczne')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Tytuł')),
              TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: 'Kwota'), keyboardType: TextInputType.number),
              
              const SizedBox(height: 16),
              CategorySelector(
                type: 'expense', 
                initialValue: _selectedCategory,
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedFrequency,
                decoration: const InputDecoration(labelText: 'Częstotliwość'),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Codziennie')),
                  DropdownMenuItem(value: 'weekly', child: Text('Tygodniowo')),
                  DropdownMenuItem(value: 'monthly', child: Text('Miesięcznie')),
                  DropdownMenuItem(value: 'yearly', child: Text('Rocznie')),
                ],
                onChanged: (val) => setState(() => _selectedFrequency = val!),
              ),

              // ... Data i Przycisk (standardowo) ...
              const SizedBox(height: 16),
              Row(children: [Text(_selectedDate == null ? 'Brak daty' : DateFormat('dd.MM.yyyy').format(_selectedDate!)), IconButton(icon: Icon(Icons.calendar_month), onPressed: _presentDatePicker)]),
              ElevatedButton(onPressed: _submitData, child: Text('Zapisz')),
            ],
          ),
        ),
      ),
    );
  }
}