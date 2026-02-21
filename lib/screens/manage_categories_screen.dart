import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final expense = provider.expenseCategories;
    final income = provider.incomeCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('Zarządzaj kategoriami')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Wydatki', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...expense.map((c) => _categoryTile(context, c.id, c.name, c.colorValue)),
              const Divider(height: 24),
              const Text('Przychody', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...income.map((c) => _categoryTile(context, c.id, c.name, c.colorValue)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showAddCategoryDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Dodaj kategorię'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryTile(BuildContext context, int id, String name, int colorValue) {
    final provider = context.read<CategoryProvider>();
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Color(colorValue)),
        title: Text(name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context, id, name, colorValue),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Usuń kategorię?'),
                    content: const Text('Ta operacja usunie kategorię. Pozycje powiązane pozostaną bez zmian.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Anuluj')),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Usuń')),
                    ],
                  ),
                );
                if (ok == true) {
                  await provider.deleteCategory(id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color selected = Colors.blue;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Nowa kategoria'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nazwa')),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  Colors.red, Colors.pink, Colors.purple, Colors.indigo,
                  Colors.blue, Colors.teal, Colors.green, Colors.lime,
                  Colors.orange, Colors.brown, Colors.blueGrey
                ].map((c) => GestureDetector(
                  onTap: () => setState(() => selected = c),
                  child: CircleAvatar(backgroundColor: c, radius: 16, child: selected == c ? const Icon(Icons.check, size: 16, color: Colors.white) : null),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Anuluj')),
            ElevatedButton(onPressed: () async {
              final text = nameController.text.trim();
              if (text.isNotEmpty) {
                await context.read<CategoryProvider>().addCategory(text, 'expense', selected);
                Navigator.pop(ctx);
              }
            }, child: const Text('Dodaj')),
          ],
        );
      }),
    );
  }

  void _showEditDialog(BuildContext context, int id, String currentName, int colorValue) {
    final nameController = TextEditingController(text: currentName);
    Color selected = Color(colorValue);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Edytuj kategorię'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nazwa')),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  Colors.red, Colors.pink, Colors.purple, Colors.indigo,
                  Colors.blue, Colors.teal, Colors.green, Colors.lime,
                  Colors.orange, Colors.brown, Colors.blueGrey
                ].map((c) => GestureDetector(
                  onTap: () => setState(() => selected = c),
                  child: CircleAvatar(backgroundColor: c, radius: 16, child: selected == c ? const Icon(Icons.check, size: 16, color: Colors.white) : null),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Anuluj')),
            ElevatedButton(onPressed: () async {
              final text = nameController.text.trim();
              if (text.isNotEmpty) {
                await context.read<CategoryProvider>().updateCategory(id, text, selected);
                Navigator.pop(ctx);
              }
            }, child: const Text('Zapisz')),
          ],
        );
      }),
    );
  }
}
