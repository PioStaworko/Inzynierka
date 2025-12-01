import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/providers/category_provider.dart';
import 'package:savings_app/data/app_database.dart';
import 'package:drift/native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CategoryProvider (with real in-memory DB)', () {
    late AppDb db;
    late CategoryProvider provider;

    setUp(() async {
      db = AppDb.test(NativeDatabase.memory());
      provider = CategoryProvider(db.categoriesDao);
      // give provider time to seed/load
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() async {
      await db.close();
    });

    test('seeds defaults when empty', () async {
      expect(provider.expenseCategories.isNotEmpty, true);
      expect(provider.incomeCategories.isNotEmpty, true);
    });

    test('addCategory adds new category', () async {
      await provider.addCategory('TestCat', 'expense', Colors.red);
      // wait for provider to reload
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.expenseCategories.any((c) => c.name == 'TestCat'), true);
    });

    test('updateCategory updates existing category', () async {
      // create a category through provider so cache is updated
      await provider.addCategory('Old', 'expense', Colors.blue);
      await Future.delayed(const Duration(milliseconds: 50));
      final id = provider.expenseCategories.firstWhere((c) => c.name == 'Old').id;
      await provider.updateCategory(id, 'NewName', Colors.green);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.expenseCategories.any((c) => c.name == 'NewName'), true);
      expect(provider.expenseCategories.any((c) => c.colorValue == Colors.green.value), true);
    });

    test('deleteCategory removes category', () async {
      await provider.addCategory('ToRemove', 'expense', Colors.orange);
      await Future.delayed(const Duration(milliseconds: 50));
      final id = provider.expenseCategories.firstWhere((c) => c.name == 'ToRemove').id;
      await provider.deleteCategory(id);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.expenseCategories.any((c) => c.name == 'ToRemove'), false);
    });
  });
}
