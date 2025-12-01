import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:savings_app/data/app_database.dart';

void main() {
  late AppDb db;
  late CategoriesDao categoriesDao;
  late ExpensesDao expensesDao;

  setUp(() async {
    db = AppDb.test(NativeDatabase.memory());
    categoriesDao = CategoriesDao(db);
    expensesDao = ExpensesDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('CategoriesDao CRUD works', () async {
    // Insert
    await categoriesDao.insertCategory(CategoriesCompanion.insert(name: 'Food', type: 'expense', colorValue: 0xFF00FF00));
    final all = await categoriesDao.getAllCategories();
    expect(all.length, 1);
    final cat = all.first;
    expect(cat.name, 'Food');

    // Update
    await categoriesDao.updateCategory(CategoriesCompanion(id: drift.Value(cat.id), name: drift.Value('Groceries'), type: drift.Value(cat.type), colorValue: drift.Value(cat.colorValue)));
    final updated = await categoriesDao.getAllCategories();
    expect(updated.first.name, 'Groceries');

    // Delete
    await categoriesDao.deleteCategory(cat.id);
    final afterDelete = await categoriesDao.getAllCategories();
    expect(afterDelete, isEmpty);
  });

  test('ExpensesDao insertExpenseWithItems and deleteExpense', () async {
    // prepare category
    await categoriesDao.insertCategory(CategoriesCompanion.insert(name: 'TestCat', type: 'expense', colorValue: 0xFF0000FF));
    final cats = await categoriesDao.getAllCategories();
    final catId = cats.first.id;

    // For insert() companions, provide raw values for required parameters.
    final expenseComp = ExpensesCompanion.insert(
      title: 'Lunch',
      amount: 12.5,
      date: DateTime.now(),
      // categoryId is nullable in the table; wrap in Value to match generated API
      categoryId: drift.Value(catId),
    );

    // Create item companions without expenseId (we'll let the DAO set it via copyWith)
    final items = [
      ExpenseItemsCompanion(
        expenseId: drift.Value.absent(),
        name: drift.Value('Sandwich'),
        amount: drift.Value(7.5),
        categoryId: drift.Value(catId),
      ),
      ExpenseItemsCompanion(
        expenseId: drift.Value.absent(),
        name: drift.Value('Drink'),
        amount: drift.Value(5.0),
        categoryId: drift.Value(catId),
      ),
    ];

    final id = await expensesDao.insertExpenseWithItems(expenseComp, items);
    expect(id, isNonZero);

    final list = await expensesDao.getRecentExpenses();
    expect(list.length, 1);
    final first = list.first;
    expect(first.expense.id, id);
    expect(first.items.length, 2);

    // Delete and ensure removed
    await expensesDao.deleteExpense(id);
    final after = await expensesDao.getRecentExpenses();
    expect(after, isEmpty);
  });
}