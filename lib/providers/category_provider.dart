// lib/providers/category_provider.dart

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final Isar isar;
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];

  CategoryProvider(this.isar) {
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    // Jeśli baza jest pusta, dodaj kategorie domyślne
    if (await isar.categorys.count() == 0) {
      await _seedDefaults();
    }
    _loadCategories();
  }

  Future<void> _seedDefaults() async {
    final defaults = [
      Category(name: 'Jedzenie', type: CategoryType.expense, colorValue: Colors.orange.value),
      Category(name: 'Transport', type: CategoryType.expense, colorValue: Colors.blue.value),
      Category(name: 'Dom', type: CategoryType.expense, colorValue: Colors.brown.value),
      Category(name: 'Rozrywka', type: CategoryType.expense, colorValue: Colors.purple.value),
      Category(name: 'Inne', type: CategoryType.expense, colorValue: Colors.grey.value),
      Category(name: 'Wypłata', type: CategoryType.income, colorValue: Colors.green.value),
      Category(name: 'Prezent', type: CategoryType.income, colorValue: Colors.amber.value),
    ];
    await isar.writeTxn(() async {
      await isar.categorys.putAll(defaults);
    });
  }

  void _loadCategories() {
    _expenseCategories = isar.categorys.filter().typeEqualTo(CategoryType.expense).findAllSync();
    _incomeCategories = isar.categorys.filter().typeEqualTo(CategoryType.income).findAllSync();
    notifyListeners();
  }

  // GETTERY
  List<Category> get expenseCategories => _expenseCategories;
  List<Category> get incomeCategories => _incomeCategories;

  // Metoda do pobierania koloru (dla wykresów i list)
  Color getColorFor(String name, CategoryType type) {
    final list = type == CategoryType.expense ? _expenseCategories : _incomeCategories;
    try {
      return Color(list.firstWhere((c) => c.name == name).colorValue);
    } catch (_) {
      return Colors.grey;
    }
  }

  // DODAWANIE NOWEJ KATEGORII
  Future<Category> addCategory(String name, CategoryType type, Color color) async {
    final newCat = Category(name: name, type: type, colorValue: color.value);
    await isar.writeTxn(() async {
      await isar.categorys.put(newCat);
    });
    _loadCategories(); // Odśwież listy
    return newCat;
  }
}