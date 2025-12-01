import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/data/app_database.dart';
import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DAO tests (in-memory AppDb)', () {
    late AppDb db;

    setUp(() async {
      db = AppDb.test(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('CategoriesDao CRUD', () async {
      // Initially empty -> provider/seeding is not used here, operate directly on DAO
      await db.categoriesDao.insertCategory(CategoriesCompanion.insert(name: 'Food', type: 'expense', colorValue: Colors.orange.value));
      await db.categoriesDao.insertCategory(CategoriesCompanion.insert(name: 'Salary', type: 'income', colorValue: Colors.green.value));

      final all = await db.categoriesDao.getAllCategories();
      expect(all.length, 2);
      expect(all.any((c) => c.name == 'Food'), true);

      // Update first category
      final first = all.firstWhere((c) => c.name == 'Food');
      await db.categoriesDao.updateCategory(CategoriesCompanion(id: drift.Value(first.id), name: drift.Value('Groceries'), type: drift.Value(first.type), colorValue: drift.Value(first.colorValue)));

      final updated = await db.categoriesDao.getAllCategories();
      expect(updated.any((c) => c.name == 'Groceries'), true);

      // Delete
      await db.categoriesDao.deleteCategory(first.id);
      final afterDelete = await db.categoriesDao.getAllCategories();
      expect(afterDelete.any((c) => c.id == first.id), false);
    });

    test('ExpensesDao insertExpenseWithItems and delete', () async {
      // Create category to attach
      await db.categoriesDao.insertCategory(CategoriesCompanion.insert(name: 'Misc', type: 'expense', colorValue: Colors.grey.value));
      final cats = await db.categoriesDao.getAllCategories();
      final catId = cats.first.id;

      final expenseComp = ExpensesCompanion.insert(title: 'Test Expense', amount: 12.34, date: DateTime.now(), categoryId: drift.Value(catId));

      final items = [
        ExpenseItemsCompanion.insert(expenseId: 0, name: 'Item A', amount: 5.00, categoryId: drift.Value(catId)),
        ExpenseItemsCompanion.insert(expenseId: 0, name: 'Item B', amount: 7.34, categoryId: drift.Value(catId)),
      ];

      final id = await db.expensesDao.insertExpenseWithItems(expenseComp, items);
      expect(id, greaterThan(0));

      final recent = await db.expensesDao.getRecentExpenses();
      expect(recent.any((r) => r.expense.id == id), true);

      // Delete and assert removed
      await db.expensesDao.deleteExpense(id);
      final after = await db.expensesDao.getRecentExpenses();
      expect(after.any((r) => r.expense.id == id), false);
    });
  });
}
