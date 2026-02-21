import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class CategorySelector extends StatefulWidget {
  final String type;
  final String? initialValue;
  final Function(String) onChanged;
  final bool isLoaded;

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
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != null) {
      setState(() {
        _currentValue = widget.initialValue;
      });
    }
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
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
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final categoryProvider = context.read<CategoryProvider>();
                    await categoryProvider.addCategory(
                      nameController.text,
                      widget.type,
                      selectedColor,
                    );
                    setState(() {
                      _currentValue = nameController.text;
                    });
                    widget.onChanged(nameController.text);
                    
                    if (mounted) Navigator.pop(ctx);
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

    if (!widget.isLoaded) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentValue != null && 
        categories.isNotEmpty && 
        !categories.any((c) => c.name == _currentValue)) {
      _currentValue = categories.first.name;
    }
    
    if (_currentValue == null && categories.isNotEmpty) {
      _currentValue = categories.first.name;
      WidgetsBinding.instance.addPostFrameCallback((_) {
         widget.onChanged(_currentValue!);
      });
    }

    return DropdownButtonFormField<String>(
      value: _currentValue,
      decoration: const InputDecoration(labelText: 'Kategoria'),
      items: [
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
        const DropdownMenuItem(
          value: '__ADD_NEW__',
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