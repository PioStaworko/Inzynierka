import 'package:flutter/material.dart';
import '../data/app_database.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoriesDao dao;
  
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];

  CategoryProvider(this.dao) {
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    if (await dao.countCategories() == 0) {
      await _seedDefaults();
    }
    _loadCategories();
  }

  Future<void> _seedDefaults() async {
    final defaults = [
      CategoriesCompanion.insert(name: 'Jedzenie', type: 'expense', colorValue: Colors.orange.toARGB32()),
      CategoriesCompanion.insert(name: 'Transport', type: 'expense', colorValue: Colors.blue.toARGB32()),
      CategoriesCompanion.insert(name: 'Dom', type: 'expense', colorValue: Colors.brown.toARGB32()),
      CategoriesCompanion.insert(name: 'Rozrywka', type: 'expense', colorValue: Colors.purple.toARGB32()),
      CategoriesCompanion.insert(name: 'Inne', type: 'expense', colorValue: Colors.grey.toARGB32()),
      CategoriesCompanion.insert(name: 'Wypłata', type: 'income', colorValue: Colors.green.toARGB32()),
      CategoriesCompanion.insert(name: 'Prezent', type: 'income', colorValue: Colors.amber.toARGB32()),
    ];
    await dao.insertAll(defaults);
  }

  void _loadCategories() async {
    final all = await dao.getAllCategories();
    _expenseCategories = all.where((c) => c.type == 'expense').toList();
    _incomeCategories = all.where((c) => c.type == 'income').toList();
    notifyListeners();
  }

  List<Category> get expenseCategories => _expenseCategories;
  List<Category> get incomeCategories => _incomeCategories;

  Color getColorFor(String name, String type) {
    final list = type == 'expense' ? _expenseCategories : _incomeCategories;
    try {
      return Color(list.firstWhere((c) => c.name == name).colorValue);
    } catch (_) {
      return Colors.grey;
    }
  }

  Future<void> addCategory(String name, String type, Color color) async {
    await dao.insertCategory(CategoriesCompanion.insert(
      name: name,
      type: type,
      colorValue: color.toARGB32(),
    ));
    _loadCategories();
  }
  
  Future<void> deleteCategory(int id) async {
    await dao.deleteCategory(id);
    _loadCategories();
  }
}