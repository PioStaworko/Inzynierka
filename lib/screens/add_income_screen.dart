import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/app_database.dart'; // Klasy Drift
import '../providers/income_provider.dart';

class AddIncomeScreen extends StatefulWidget {
  final Income? incomeToEdit;

  const AddIncomeScreen({super.key, this.incomeToEdit});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.incomeToEdit != null) {
      final i = widget.incomeToEdit!;
      _titleController = TextEditingController(text: i.title);
      _amountController = TextEditingController(text: i.amount.toString());
      _selectedDate = i.date;
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
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (pickedDate != null) {
      setState(() { _selectedDate = pickedDate; });
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) return;

    final enteredAmount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (enteredAmount == null || enteredAmount <= 0) return;

    final provider = context.read<IncomeProvider>();

    if (widget.incomeToEdit != null) {
        await provider.deleteIncome(widget.incomeToEdit!.id); 
        await provider.addIncome(
          _titleController.text,
          enteredAmount,
          _selectedDate!,
        );
    } else {
      await provider.addIncome(
        _titleController.text,
        enteredAmount,
        _selectedDate!,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: const Text('Dodaj przychód')),
       body: Padding(
         padding: const EdgeInsets.all(16),
         child: Form(
            key: _formKey,
            child: ListView(
              children: [
                 TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Tytuł')),
                 TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: 'Kwota'), keyboardType: TextInputType.number),
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
                    icon: const Icon(Icons.save),
                    label: const Text('Zapisz'),
                  ),
              ]
            )
         )
       )
    );
  }
}