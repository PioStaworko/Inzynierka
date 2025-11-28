// lib/widgets/category_selector.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class CategorySelector extends StatefulWidget {
  final String type; // <--- Zmieniamy z Enum na String ('expense' lub 'income')
  final String? initialValue;
  final Function(String) onChanged;
  final bool isLoaded; // jeśli false, pokazujemy placeholder/loading

  const CategorySelector({
    super.key,
    required this.type,
    required this.onChanged,
    this.initialValue,
    this.isLoaded = true,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jeśli rodzic podał nową wartość początkową, aktualizujemy stan
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != null) {
      setState(() {
        _currentValue = widget.initialValue;
      });
    }
  }

  // Funkcja otwierająca okienko dodawania
  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue; // Domyślny kolor nowej kategorii

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( // StatefulBuilder potrzebny do odświeżania wyboru koloru w dialogu
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Nowa kategoria'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nazwa kategorii'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                const Text('Wybierz kolor:'),
                const SizedBox(height: 8),
                // Prosta paleta kolorów
                Wrap(
                  spacing: 10,
                  children: [
                    Colors.red, Colors.pink, Colors.purple, Colors.indigo,
                    Colors.blue, Colors.teal, Colors.green, Colors.lime,
                    Colors.orange, Colors.brown, Colors.blueGrey
                  ].map((color) {
                    return GestureDetector(
                      onTap: () => setStateDialog(() => selectedColor = color),
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 14,
                        child: selectedColor == color
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx), // Anuluj -> zamknij dialog
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    // Capture provider before awaiting to avoid using BuildContext across async gaps
                    final categoryProvider = context.read<CategoryProvider>();
                    // 1. Zapisz w bazie przez Provider
                    await categoryProvider.addCategory(
                      nameController.text,
                      widget.type,
                      selectedColor,
                    );
                    // 2. Ustaw nową wartość w dropdownie
                    setState(() {
                      _currentValue = nameController.text;
                    });
                    // 3. Przekaż do formularza rodzica
                    widget.onChanged(nameController.text);
                    
                    if (mounted) Navigator.pop(ctx); // Zamknij dialog
                  }
                },
                child: const Text('Dodaj'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final categories = widget.type == 'expense'
        ? provider.expenseCategories
        : provider.incomeCategories;

    // Jeśli komponent nie jest jeszcze załadowany (np. czekamy na DB), pokaż placeholder
    if (!widget.isLoaded) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Zabezpieczenie: jeśli wybrana kategoria została usunięta, resetuj
    if (_currentValue != null && 
        categories.isNotEmpty && 
        !categories.any((c) => c.name == _currentValue)) {
      _currentValue = categories.first.name;
    }
    
    // Jeśli wciąż null (np. pusta baza), ustaw na pierwszy element
    if (_currentValue == null && categories.isNotEmpty) {
      _currentValue = categories.first.name;
      // Ważne: poinformuj rodzica o domyślnej wartości przy pierwszym renderze
      WidgetsBinding.instance.addPostFrameCallback((_) {
         widget.onChanged(_currentValue!);
      });
    }

    return DropdownButtonFormField<String>(
      initialValue: _currentValue,
      decoration: const InputDecoration(labelText: 'Kategoria'),
      items: [
        // 1. Lista istniejących kategorii
        ...categories.map((cat) {
          return DropdownMenuItem(
            value: cat.name,
            child: Row(
              children: [
                Icon(Icons.circle, color: Color(cat.colorValue), size: 12),
                const SizedBox(width: 10),
                Text(cat.name),
              ],
            ),
          );
        }),
        // 2. Opcja specjalna na końcu
        const DropdownMenuItem(
          value: '__ADD_NEW__', // Specjalna wartość
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.grey),
              SizedBox(width: 10),
              Text('Dodaj nową...', style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value == '__ADD_NEW__') {
          // Jeśli wybrano "Dodaj...", nie zmieniaj wartości dropdowna na to, 
          // tylko otwórz dialog.
          _showAddDialog(context);
        } else if (value != null) {
          setState(() {
            _currentValue = value;
          });
          widget.onChanged(value);
        }
      },
    );
  }
}