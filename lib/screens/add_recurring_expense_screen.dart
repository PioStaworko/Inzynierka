// lib/screens/add_recurring_expense_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/app_database.dart';
import '../providers/recurring_expense_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/category_selector.dart';

class AddRecurringExpenseScreen extends StatefulWidget {
  final RecurringExpense? expenseToEdit;

  const AddRecurringExpenseScreen({super.key, this.expenseToEdit});

  @override
  State<AddRecurringExpenseScreen> createState() => _AddRecurringExpenseScreenState();
}

class _AddRecurringExpenseScreenState extends State<AddRecurringExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  DateTime? _selectedDate;
  String _selectedCategory = 'Inne';
  String _selectedFrequency = 'monthly'; // String zamiast Enum

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final e = widget.expenseToEdit!;
      _titleController = TextEditingController(text: e.title);
      _amountController = TextEditingController(text: e.amount.toString());
      _selectedDate = e.nextDueDate;
      // Resolve category id -> name using CategoryProvider
      try {
        final catProv = Provider.of<CategoryProvider>(context, listen: false);
        _selectedCategory = catProv.getNameForId(e.categoryId);
      } catch (_) {
        _selectedCategory = 'Inne';
      }
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

    final provider = context.read<RecurringExpenseProvider>();

    if (widget.expenseToEdit != null) {
      await provider.updateRecurringExpenseByFields(
        widget.expenseToEdit!.id,
        _titleController.text,
        enteredAmount,
        _selectedCategory,
        _selectedFrequency,
        _selectedDate!,
      );
    } else {
      await provider.addRecurringExpense(
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
      appBar: AppBar(title: const Text('Wydatki cykliczne')),
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