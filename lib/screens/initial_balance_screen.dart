import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/starting_balance_provider.dart';

class InitialBalanceScreen extends StatefulWidget {
  const InitialBalanceScreen({super.key});

  @override
  State<InitialBalanceScreen> createState() => _InitialBalanceScreenState();
}

class _InitialBalanceScreenState extends State<InitialBalanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cashController = TextEditingController();
  final _bankController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _cashController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final parsed = double.tryParse(v.replaceAll(',', '.'));
    if (parsed == null) return 'Niepoprawna liczba';
    if (parsed < 0) return 'Wartość nie może być ujemna';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final cash = double.tryParse(_cashController.text.replaceAll(',', '.')) ?? 0.0;
    final bank = double.tryParse(_bankController.text.replaceAll(',', '.')) ?? 0.0;
    await context.read<StartingBalanceProvider>().setBalances(cash: cash, bank: bank);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _skip() async {
    await context.read<StartingBalanceProvider>().skip();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat.currency(locale: 'pl_PL', symbol: '', decimalDigits: 2);
    return Scaffold(
      appBar: AppBar(title: const Text('Wprowadź stan początkowy')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Na początek podaj ile masz teraz pieniędzy. To umożliwi poprawne wyliczanie salda i wykresów.'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cashController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Gotówka (PLN)', hintText: nf.format(0)),
                validator: _validateAmount,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bankController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Stan konta (PLN)', hintText: nf.format(0)),
                validator: _validateAmount,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Zapisz'),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _skip, child: const Text('Pomiń')),
            ],
          ),
        ),
      ),
    );
  }
}
